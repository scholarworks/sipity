module Sipity
  module Forms
    module Etd
      # Responsible for creating a new work within the ETD work area.
      # What goes into this is more complicated that the entity might allow.
      class StartASubmissionForm < BaseForm
        include Conversions::SanitizeHtml
        self.policy_enforcer = Policies::WorkPolicy

        def self.model_name
          Models::Work.model_name
        end

        def initialize(attributes = {})
          self.title = attributes[:title]
          self.work_publication_strategy = attributes[:work_publication_strategy]
          self.work_type = attributes[:work_type]
          self.access_rights_answer = attributes.fetch(:access_rights_answer) { default_access_rights_answer }
          self.repository = attributes.fetch(:repository) { default_repository }
          initialize_work_area!
          self.submission_window = attributes.fetch(:submission_window) { default_submission_window }
        end

        attr_accessor :repository, :title, :work_publication_strategy, :work_type, :access_rights_answer
        private(:repository, :repository=, :title=, :work_publication_strategy=, :work_type=, :access_rights_answer=)

        validates :title, presence: true
        validates :work_publication_strategy, presence: true, inclusion: { in: :possible_work_publication_strategies }
        validates :work_type, presence: true, inclusion: { in: :possible_work_types }
        validates :access_rights_answer, presence: true, inclusion: { in: :possible_access_right_answers }
        validates :submission_window, presence: true

        # TODO: Extract a work area collaborator; How does that reconcile with
        #   the submission window.
        def to_work_area
          work_area
        end

        def access_rights_answer_for_select
          possible_access_right_answers.map(&:to_sym)
        end

        def work_publication_strategies_for_select
          possible_work_publication_strategies.map { |elem| elem.first.to_sym }
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
            repository.handle_transient_access_rights_answer(entity: work, answer: access_rights_answer)
            repository.grant_creating_user_permission_for!(entity: work, user: requested_by)

            # TODO: See https://github.com/ndlib/sipity/issues/506
            repository.send_notification_for_entity_trigger(
              notification: "confirmation_of_work_created", entity: work, acting_as: 'creating_user'
            )
            repository.log_event!(entity: work, user: requested_by, event_name: event_name)
          end
        end

        private

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
          DataGenerators::Etd::WorkTypesProcessingGenerator::WORK_TYPE_NAMES
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
          File.join(self.class.to_s.demodulize.underscore, 'submit')
        end

        def default_repository
          CommandRepository.new
        end

        attr_reader :submission_window, :work_area

        DEFAULT_WORK_AREA_SLUG = 'etd'.freeze
        DEFAULT_SUBMISSION_WINDOW_SLUG = 'start'.freeze
        def default_submission_window
          repository.find_submission_window_by(slug: DEFAULT_SUBMISSION_WINDOW_SLUG, work_area: work_area)
        end

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
