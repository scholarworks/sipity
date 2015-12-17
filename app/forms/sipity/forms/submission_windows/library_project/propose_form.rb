require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module SubmissionWindows
      module LibraryProject
        # Responsible for creating a proposal for the LibraryProject
        class ProposeForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :submission_window,
            policy_enforcer: Policies::SubmissionWindowPolicy,
            attribute_names: [:title]
          )

          def initialize(submission_window:, requested_by:, attributes: {}, **keywords)
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_work_area_and_submission_window!(submission_window: submission_window)
            self.title = attributes[:title]
            self.work_type = Models::WorkType::LIBRARY_PROJECT_PROPOSAL
          end

          private

          attr_reader :work_area
          attr_accessor :work_type

          public

          attr_reader :work
          alias_method :to_work_area, :work_area
          public :to_work_area

          delegate :slug, :work_area_slug, to: :submission_window

          include ActiveModel::Validations
          validates :submission_window, presence: true, open_for_starting_submissions: true
          validates :requested_by, presence: true
          validates :title, presence: true

          def submit
            return false unless valid?
            save
          end

          private

          def save
            create_the_work do |work|
              # I believe this form has too much knowledge of what is going on;
              # Consider pushing some of the behavior down into the repository.
              repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
              register_actions
            end
          end

          def register_actions
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

          def create_the_work
            @work = repository.create_work!(submission_window: submission_window, title: title, work_type: work_type)
            yield(@work)
            @work
          end

          def default_repository
            CommandRepository.new
          end

          def event_name
            File.join(processing_action_name, 'submit')
          end

          def initialize_work_area_and_submission_window!(submission_window:)
            @work_area = repository.find_work_area_by(slug: DataGenerators::WorkAreas::LibraryProjectGenerator::SLUG)
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
