module Sipity
  # :nodoc:
  module Commands
    # REVIEW: Is this the best place to put this information? Do I want to
    #   persist this in a database? Does that make sense?
    #
    # REVIEW: Considere that some enrichments are not required. This associates
    #   the enrichments with the entity, but does not assert policies related to
    #   each enrichment; I believe that is the correct way to do things.
    WORK_TYPE_PROCESSING_STATE_TODO_LIST_ITEMS = {
      'etd' => {
        'new' => ['attach', 'describe']
      }
    }.freeze

    # Responsible for interaction with the todo list.
    module TodoListCommands
      def create_work_todo_list_for_current_state(work:, processing_state: work.processing_state, work_type: work.work_type)
        WORK_TYPE_PROCESSING_STATE_TODO_LIST_ITEMS.fetch(work_type).fetch(processing_state).each do |item_name|
          create_named_entity_todo_item_for_current_state(entity: work, entity_processing_state: processing_state, enrichment_type: item_name)
        end
      end

      def mark_work_todo_item_as_done(work:, enrichment_type:, processing_state: work.processing_state)
        # # Yes Rails handles this, but I don't want to have to persist
        # entity_id = work.id
        # entity_type = Conversions::ConvertToPolymorphicType.call(work)
        item = Models::TodoItemState.where(entity: work, enrichment_type: enrichment_type, entity_processing_state: processing_state).first!
        item.update(enrichment_state: Models::TodoItemState::ENRICHMENT_STATE_DONE)
      end

      private

      def create_named_entity_todo_item_for_current_state(entity:, entity_processing_state:, enrichment_type:)
        entity_id = entity.id
        entity_type = Conversions::ConvertToPolymorphicType.call(entity)
        Models::TodoItemState.create!(
          entity_id: entity_id,
          entity_type: entity_type,
          entity_processing_state: entity_processing_state,
          enrichment_type: enrichment_type
        )
      end
    end
    private_constant :TodoListCommands
  end
end
