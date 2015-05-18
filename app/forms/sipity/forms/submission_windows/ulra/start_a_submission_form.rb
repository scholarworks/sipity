module Sipity
  module Forms
    module SubmissionWindows
      module Ulra
        # Responsible for creating a new work within the ULRA work area.
        # What goes into this is more complicated that the entity might allow.
        class StartASubmissionForm < SubmissionWindows::BaseForm
          class_attribute :base_class, :policy_enforcer

          self.base_class = Models::SubmissionWindow
          self.policy_enforcer = Policies::SubmissionWindowPolicy

          class << self
            # Because ActiveModel::Validations is included at the class level,
            # and thus makes assumptions. Without `.model_name` method, the
            # validations choke.
            #
            # Do not delegate .name to the .base_class; Things will fall apart.
            #
            # @note This needs to be done after the ActiveModel::Validations,
            #   otherwise you will get the dreaded error:
            #
            #   ```console
            #   A copy of Sipity::Forms::SubmissionWindows::Ulra::StartASubmissionForm
            #   has been removed from the module tree but is still active!
            #   ```
            delegate :model_name, :human_attribute_name, to: :base_class
          end

          def initialize(submission_window:, attributes: {}, **collaborators)
            self.repository = collaborators.fetch(:repository) { default_repository }
            self.processing_action_name = collaborators.fetch(:processing_action_name) { default_processing_action_name }
            initialize_work_area!
            self.submission_window = submission_window
            initialize_attributes(attributes)
          end

          def award_categories_for_select
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'award_category')
          end

          attr_reader :title, :award_category, :work_publication_strategy, :advisor_netid, :work_type

          private

          attr_accessor :processing_action_name, :repository, :localization_assistant
          attr_writer :repository, :title, :award_category, :work_publication_strategy, :advisor_netid, :work_type
          attr_reader :submission_window, :work_area

          public

          delegate :to_processing_entity, :slug, :work_area_slug, to: :submission_window
          alias_method :to_model, :submission_window

          include ActiveModel::Validations
          validates :title, presence: true
          validates :award_category, presence: true, inclusion: { in: :award_categories_for_select }
          validates :advisor_netid, presence: true, net_id: true
          validates :work_publication_strategy, presence: true, inclusion: { in: :possible_work_publication_strategies }
          validates :work_type, presence: true
          validates :submission_window, presence: true

          def work_publication_strategies_for_select
            possible_work_publication_strategies.map { |elem| elem.first.to_sym }
          end

          def submit(requested_by:)
            return false unless valid?
            create_the_work do |work|
              # I believe this form has too much knowledge of what is going on;
              # Consider pushing some of the behavior down into the repository.
              repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
              repository.log_event!(entity: work, user: requested_by, event_name: event_name)
            end
          end

          # TODO: Extract a work area collaborator; How does that reconcile with
          #   the submission window.
          def to_work_area
            work_area
          end

          def to_key
            []
          end

          def to_param
            nil
          end

          def persisted?
            to_param.nil? ? false : true
          end

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
            work = repository.create_work!(
              submission_window: submission_window,
              title: title,
              advisor_netid: advisor_netid,
              award_category: award_category,
              work_publication_strategy: work_publication_strategy,
              work_type: work_type
            )
            yield(work)
            work
          end

          def default_work_type
            Models::WorkType::ULRA_SUBMISSION
          end

          def possible_work_publication_strategies
            Models::Work.work_publication_strategies
          end

          def event_name
            File.join(processing_action_name, 'submit')
          end

          def default_repository
            CommandRepository.new
          end

          DEFAULT_WORK_AREA_SLUG = 'ulra'.freeze
          def initialize_work_area!
            @work_area = repository.find_work_area_by(slug: DEFAULT_WORK_AREA_SLUG)
          end

          def submission_window=(input)
            @submission_window = PowerConverter.convert(input, to: :submission_window, scope: work_area)
          end

          PROCESSING_ACTION_NAME = 'start_a_submission'.freeze
          def default_processing_action_name
            PROCESSING_ACTION_NAME
          end
        end
      end
    end
  end
end
