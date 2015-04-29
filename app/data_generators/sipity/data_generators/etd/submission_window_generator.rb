module Sipity
  module DataGenerators
    module Etd
      # Responsible for generating the submission window for the ETD work area.
      class SubmissionWindowGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::DOCTORAL_DISSERTATION,
          Models::WorkType::MASTER_THESIS
        ]
        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, submission_window:)
          self.work_area = work_area
          self.submission_window = submission_window
        end

        private

        attr_reader :submission_window, :work_area

        def work_area=(input)
          @work_area = PowerConverter.convert_to_work_area(input)
        end

        def submission_window=(input)
          @submission_window = PowerConverter.convert(input, to: :submission_window, scope: work_area)
        end

        public

        def call
          save_submission_window_if_applicable!
          associate_work_types_with_permission_window!
        end

        private

        def save_submission_window_if_applicable!
          submission_window.save! unless submission_window.persisted?
        end

        def associate_work_types_with_permission_window!
          WORK_TYPE_NAMES.each do |work_type_name|
            work_type = PowerConverter.convert_to_work_type(work_type_name)
            submission_window.submission_window_work_types.find_or_create_by!(work_type: work_type)
          end
        end
      end
    end
  end
end
