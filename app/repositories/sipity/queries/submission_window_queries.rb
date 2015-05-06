module Sipity
  module Queries
    # Queries related to SubmissionWindows.
    module SubmissionWindowQueries
      def find_submission_window_by(slug:, work_area:)
        work_area = PowerConverter.convert_to_work_area(work_area)
        Models::SubmissionWindow.find_by!(slug: slug, work_area_id: work_area.id)
      end
    end
  end
end
