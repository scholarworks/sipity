module Sipity
  module Forms
    module Etd
      # Responsible for creating a new work within the ETD work area.
      # What goes into this is more complicated that the entity might allow.
      class StartASubmissionForm < Sipity::Forms::CreateWorkForm
        def initialize(attributes = {})
          super(attributes)
          initialize_work_area!
          self.submission_window = attributes.fetch(:submission_window) { default_submission_window }
        end

        validates :submission_window, presence: true

        private

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
