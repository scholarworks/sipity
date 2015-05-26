require 'sipity/forms/work_submissions'

module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      def build_enrichment_form(attributes = {})
        work = attributes.fetch(:work)
        processing_action_name = attributes.fetch(:enrichment_type)
        Forms::WorkSubmissions.build_the_form(
          work: work,
          processing_action_name: processing_action_name,
          attributes: attributes.except(:work, :enrichment_type),
          repository: self
        )
      end
    end
  end
end
