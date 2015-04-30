module Sipity
  module Queries
    # Queries related to work areas.
    module WorkAreaQueries
      def find_work_area_by(slug:)
        Models::WorkArea.where(slug: slug).first!
      end

      def find_submission_window_by(slug:, work_area:)
        work_area = PowerConverter.convert_to_work_area(work_area)
        Models::SubmissionWindow.find_by!(slug: slug, work_area: work_area)
      end
    end
  end
end
