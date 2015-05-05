module Sipity
  module Queries
    # Queries related to work areas.
    module WorkAreaQueries
      def find_work_area_by(slug:)
        Models::WorkArea.where(slug: slug).first!
      end

      # TODO: Extract to a Submission Window query? Not necessary but may be
      # helpful going forward.
      def find_submission_window_by(slug:, work_area:)
        work_area = PowerConverter.convert_to_work_area(work_area)
        Models::SubmissionWindow.find_by!(slug: slug, work_area: work_area)
      end

      def build_work_area_processing_action_form(work_area:, processing_action_name:, attributes: {})
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::WorkAreaForms.build_the_form(
          work_area: work_area,
          processing_action_name: processing_action_name,
          attributes: attributes
        )
      end
    end
  end
end
