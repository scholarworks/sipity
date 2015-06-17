module Sipity
  module Queries
    # Queries related to work areas.
    module WorkAreaQueries
      def find_work_area_by(slug:)
        Models::WorkArea.find_by!(slug: slug)
      end

      def build_work_area_processing_action_form(work_area:, processing_action_name:, **keywords)
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::WorkAreas.build_the_form(
          work_area: work_area,
          processing_action_name: processing_action_name,
          repository: self,
          **keywords
        )
      end
    end
  end
end
