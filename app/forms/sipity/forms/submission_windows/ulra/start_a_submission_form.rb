require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module SubmissionWindows
      module Ulra
        # Responsible for creating a new work within the ULRA work area.
        # What goes into this is more complicated that the entity might allow.
        class StartASubmissionForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :submission_window,
            policy_enforcer: Policies::SubmissionWindowPolicy,
            attribute_names: [:title, :work_publication_strategy, :award_category, :advisor_netid, :work_type]
          )

          def initialize(submission_window:, requested_by:, attributes: {}, **keywords)
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.publication_and_patenting_intent_extension = publication_and_patenting_intent_extension_builder.new(
              form: self, repository: repository
            )
            initialize_work_area_and_submission_window!(submission_window: submission_window)
            initialize_attributes(attributes)
          end

          delegate(
            :work_publication_strategy, :work_publication_strategy=, :work_publication_strategies_for_select,
            :possible_work_publication_strategies, :persist_work_publication_strategy,
            to: :publication_and_patenting_intent_extension
          )

          private(:work_publication_strategy=, :possible_work_publication_strategies, :persist_work_publication_strategy)

          private

          attr_reader :work_area
          attr_accessor :publication_and_patenting_intent_extension

          def publication_and_patenting_intent_extension_builder
            Forms::ComposableElements::PublishingAndPatentingIntentExtension
          end

          public

          def award_categories_for_select
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'award_category')
          end

          delegate :slug, :work_area_slug, to: :submission_window

          attr_reader :work

          include ActiveModel::Validations
          validates :title, presence: true
          validates :award_category, presence: true, inclusion: { in: :award_categories_for_select }
          validates :advisor_netid, presence: true, net_id: true
          validates :work_publication_strategy, presence: true, inclusion: { in: :possible_work_publication_strategies }
          validates :work_type, presence: true
          validates :submission_window, presence: true, open_for_starting_submissions: true
          validates :requested_by, presence: true

          def submit
            return false unless valid?
            save
          end

          private

          def save
            create_the_work do |work|
              persist_work_publication_strategy
              # I believe this form has too much knowledge of what is going on;
              # Consider pushing some of the behavior down into the repository.
              repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
              repository.assign_collaborators_to(work: work, collaborators: build_collaborator(work: work))
              register_actions(work: work)
            end
          end

          def build_collaborator(work:)
            # HACK: I don't like the name as netid nor do I like the role as RESEARCH_DIRECTOR_ROLE, however, I'm pressed for time so
            # I'm making a compromise. The alternative is a larger systemic change that will need to come later.
            Models::Collaborator.new(
              work: work, name: advisor_netid, netid: advisor_netid, role: Models::Collaborator::RESEARCH_DIRECTOR_ROLE
            )
          end

          def register_actions(work:)
            # TODO: See Etd::StartASubmissionForm for common behavior
            #
            # Your read that right, register actions on both the work and submission window.
            # This form crosses a conceptual boundary. I need permission within
            # the submission window to create a work. However, I want to
            # notify the creating user of the work of the action they've taken.
            repository.register_action_taken_on_entity(entity: work, action: processing_action_name, requested_by: requested_by)
            repository.register_action_taken_on_entity(
              entity: submission_window, action: processing_action_name, requested_by: requested_by
            )
            repository.log_event!(entity: work, requested_by: requested_by, event_name: event_name)
          end

          alias_method :to_work_area, :work_area
          public :to_work_area

          private

          def initialize_attributes(attributes)
            self.title = attributes[:title]
            self.advisor_netid = attributes[:advisor_netid]
            self.award_category = attributes[:award_category]
            self.work_type = attributes.fetch(:work_type) { default_work_type }
            self.work_publication_strategy = attributes[:work_publication_strategy]
          end

          include Conversions::SanitizeHtml
          def title=(value)
            @title = sanitize_html(value)
          end

          def create_the_work
            @work = repository.create_work!(
              submission_window: submission_window,
              title: title,
              advisor_netid: advisor_netid,
              award_category: award_category,
              work_type: work_type
            )
            yield(@work)
            @work
          end

          def default_work_type
            Models::WorkType::ULRA_SUBMISSION
          end

          def event_name
            File.join(processing_action_name, 'submit')
          end

          def default_repository
            CommandRepository.new
          end

          DEFAULT_WORK_AREA_SLUG = 'ulra'.freeze
          def initialize_work_area_and_submission_window!(submission_window:)
            @work_area = repository.find_work_area_by(slug: DEFAULT_WORK_AREA_SLUG)
            self.submission_window = submission_window
          end

          def submission_window=(input)
            @submission_window = PowerConverter.convert(input, to: :submission_window, scope: work_area)
          end
        end
      end
    end
  end
end
