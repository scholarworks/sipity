module Sipity
  module Queries
    # Queries
    module EnrichmentQueries
      # TODO: Consolidate :build_enrichment_form and
      #   :build_create_describe_work_form
      #
      # TODO: This is the wrong form, but works to solve the specified test.
      def build_enrichment_form(attributes = {})
        enrichment_type = attributes.fetch(:enrichment_type)
        builder = begin
          case enrichment_type
          when 'attach' then Forms::AttachFilesToWorkForm
          when 'describe' then Forms::DescribeWorkEnrichmentForm
          else
            fail Exceptions::EnrichmentNotFoundError, name: enrichment_type, container: 'EnrichmentTypes(Virtual)'
          end
        end

        builder.new(attributes)
      end

      def todo_list_for_current_processing_state_of_work(work:, processing_state: work.processing_state)
        # TODO: Can I tease apart the collaborator? I'd like to send a builder object
        # as a parameter. It would ease the entaglement that is happening here.
        Decorators::TodoList.new(entity: work) do |list|
          Models::TodoItemState.where(entity: work, entity_processing_state: processing_state).each do |todo_item|
            # REVIEW: Why is this the 'required' set; It should be based on something else.
            # For now, however, it stands.
            list.add_to(set: 'required', name: todo_item.enrichment_type, state: todo_item.enrichment_state)
          end
        end
      end
      module_function :todo_list_for_current_processing_state_of_work
      public :todo_list_for_current_processing_state_of_work
    end
  end
end
