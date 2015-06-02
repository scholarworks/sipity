module Sipity
  module Forms
    module SubmissionWindows
      module Etd
        # Responsible for creating a new work within the ETD work area.
        # What goes into this is more complicated that the entity might allow.
        class StartASubmissionForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :submission_window,
            policy_enforcer: Policies::SubmissionWindowPolicy,
            attribute_names: [:title, :work_publication_strategy, :work_patent_strategy, :work_type, :access_rights_answer]
          )

          def initialize(submission_window:, attributes: {}, **keywords)
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_work_area!
            self.submission_window = submission_window
            initialize_attributes(attributes)
          end

          private

          attr_reader :work_area

          def initialize_attributes(attributes = {})
            self.title = attributes[:title]
            self.work_publication_strategy = attributes[:work_publication_strategy]
            self.work_patent_strategy = attributes[:work_patent_strategy]
            self.work_type = attributes[:work_type]
            self.access_rights_answer = attributes.fetch(:access_rights_answer) { default_access_rights_answer }
          end

          public

          alias_method :to_work_area, :work_area
          public :to_work_area

          delegate :slug, :work_area_slug, to: :submission_window

          include ActiveModel::Validations
          validates :title, presence: true
          validates :work_patent_strategy, presence: true, inclusion: { in: :possible_work_patent_strategies }
          validates :work_publication_strategy, presence: true, inclusion: { in: :possible_work_publication_strategies }
          validates :work_type, presence: true, inclusion: { in: :possible_work_types }
          validates :access_rights_answer, presence: true, inclusion: { in: :possible_access_right_answers }
          validates :submission_window, presence: true

          def form_path
            File.join(PowerConverter.convert_to_processing_action_root_path(submission_window), processing_action_name)
          end

          def access_rights_answer_for_select
            possible_access_right_answers.map(&:to_sym)
          end

          def work_publication_strategies_for_select
            # Because we have an Array / Hash
            possible_work_publication_strategies.map { |elem| elem.first.to_sym }
          end

          def work_patent_strategies_for_select
            possible_work_patent_strategies.map(&:to_sym)
          end

          # Convert string to to_sym since simple_forn require sym to
          # look_up 18n translation for work_type
          def work_types_for_select
            possible_work_types.map(&:to_sym)
          end

          def submit(requested_by:)
            return false unless valid?
            create_the_work do |work|
              # I believe this form has too much knowledge of what is going on;
              # Consider pushing some of the behavior down into the repository.
              persist_access_rights_answer(work: work)
              persist_work_patent_strategy(work: work)
              grant_creating_user_permission(work: work, requested_by: requested_by)

              # TODO: See https://github.com/ndlib/sipity/issues/506
              repository.send_notification_for_entity_trigger(
                notification: "confirmation_of_work_created", entity: work, acting_as: 'creating_user'
              )
              repository.log_event!(entity: work, user: requested_by, event_name: event_name)
            end
          end

          private

          def persist_work_patent_strategy(work:)
            repository.update_work_attribute_values!(work: work, key: work_patent_strategy_predicate_name, values: work_patent_strategy)
          end

          def persist_access_rights_answer(work:)
            repository.handle_transient_access_rights_answer(entity: work, answer: access_rights_answer)
          end

          def grant_creating_user_permission(work:, requested_by:)
            repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
          end

          include Conversions::SanitizeHtml
          def title=(value)
            @title = sanitize_html(value)
          end

          def create_the_work
            work = repository.create_work!(
              submission_window: submission_window, title: title, work_publication_strategy: work_publication_strategy, work_type: work_type
            )
            yield(work)
            work
          end

          def possible_work_types
            # Yikes?
            DataGenerators::WorkTypes::EtdGenerator::WORK_TYPE_NAMES
          end

          def possible_work_patent_strategies
            repository.get_controlled_vocabulary_values_for_predicate_name(name: work_patent_strategy_predicate_name)
          end

          def possible_work_publication_strategies
            Models::Work.work_publication_strategies
          end

          def possible_access_right_answers
            Models::TransientAnswer.access_rights_questions
          end

          def default_access_rights_answer
            Models::TransientAnswer::ACCESS_RIGHTS_PRIVATE
          end

          def event_name
            File.join(processing_action_name, 'submit')
          end

          def default_repository
            CommandRepository.new
          end

          def work_patent_strategy_predicate_name
            Models::AdditionalAttribute::WORK_PATENT_STRATEGY
          end

          DEFAULT_WORK_AREA_SLUG = 'etd'.freeze
          def initialize_work_area!
            @work_area = repository.find_work_area_by(slug: DEFAULT_WORK_AREA_SLUG)
          end

          def submission_window=(input)
            @submission_window = PowerConverter.convert(input, to: :submission_window, scope: work_area)
          end
        end
      end
    end
  end
end
