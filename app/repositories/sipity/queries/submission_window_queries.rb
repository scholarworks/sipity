module Sipity
  module Queries
    # Queries related to SubmissionWindows.
    module SubmissionWindowQueries
      def find_submission_window_by(slug:, work_area:)
        work_area = PowerConverter.convert_to_work_area(work_area)
        Models::SubmissionWindow.find_by!(slug: slug, work_area_id: work_area.id)
      end

      def build_submission_window_processing_action_form(submission_window:, processing_action_name:, attributes: {})
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::SubmissionWindowForms.build_the_form(
          submission_window: submission_window,
          processing_action_name: processing_action_name,
          attributes: attributes
        )
      end
    end
  end
end
