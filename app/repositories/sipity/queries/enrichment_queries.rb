module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      def build_create_describe_work_form(attributes = {})
        build_enrichment_form(attributes.merge(enrichment_type: 'describe'))
      end
      deprecate :build_create_describe_work_form

      # TODO: Consolidate :build_enrichment_form and
      #   :build_create_describe_work_form
      #
      # TODO: This is the wrong form, but works to solve the specified test.
      def build_enrichment_form(attributes = {})
        enrichment_type = attributes.fetch(:enrichment_type)
        builder = begin
          case enrichment_type
          when 'attach' then Forms::AttachFilesToWorkForm
          when 'describe' then Forms::DescribeWorkForm
          else
            fail Exceptions::EnrichmentNotFoundError, name: enrichment_type, container: 'EnrichmentTypes(Virtual)'
          end
        end

        builder.new(attributes)
      end
    end
  end
end
