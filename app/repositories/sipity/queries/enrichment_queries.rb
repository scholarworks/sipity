require 'sipity/forms/work_enrichments'

module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      # This is a refactoring step. Remove once processing queries are spliced
      # in.
      include Queries::ProcessingQueries

      def build_enrichment_form(attributes = {})
        enrichment_type = attributes.fetch(:enrichment_type)
        builder = Forms::WorkEnrichments.find_enrichment_form_builder(enrichment_type: enrichment_type)
        builder.new(attributes)
      end

      def are_all_of_the_required_todo_items_done_for_work?(work:)
        # TODO: Convert this into a single query instead of three queries.
        (
          scope_strategy_actions_for_current_state(entity: work).pluck(:id) -
          scope_strategy_actions_with_completed_prerequisites(entity: work).pluck(:id) -
          scope_strategy_actions_without_prerequisites(entity: work).pluck(:id)
        ).empty?
      end
    end
  end
end
