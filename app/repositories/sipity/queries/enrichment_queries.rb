require 'sipity/forms/work_enrichments'

module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      def build_enrichment_form(attributes = {})
        enrichment_type = attributes.fetch(:enrichment_type)
        builder = Forms::WorkEnrichments.find_enrichment_form_builder(enrichment_type: enrichment_type)
        builder.new(attributes)
      end
    end
  end
end
