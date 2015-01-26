module Sipity
  # :nodoc:
  module Commands
    # Responsible for interaction with the todo list.
    module TodoListCommands
      # @note Is it reasonable to throw an exception related to completion of an
      #   enrichment todo item if we don't have record of that todo item? The
      #   authorization layer said this enrichment was valid, so lets go ahead
      #   and track that information.
      #
      #   How might this happen? I don't know, but it is in the realm of
      #   possible; And to assume otherwise is to throw an exception on a user
      #   taking an action that they:
      #
      #   * knew of the action to take
      #   * were authorized to take the action
      #   * and submitted valid data for the action
      #
      #   I don't want to throw an exception assuming the above list is true.
      #   And I don't want to ignore the work they've done; because they may
      #   need to go back and amend that work.
      def mark_work_todo_item_as_done(work:, enrichment_type:, processing_state: work.processing_state)
        done_enrichment_state = Models::TodoItemState::ENRICHMENT_STATE_DONE
        item = Models::TodoItemState.where(entity: work, enrichment_type: enrichment_type, entity_processing_state: processing_state).first
        if item
          item.update(enrichment_state: done_enrichment_state)
        else
          create_named_entity_todo_item_for_current_state(
            entity: work, entity_processing_state: processing_state,
            enrichment_type: enrichment_type, enrichment_state: done_enrichment_state
          )
        end
      end

      private

      def create_named_entity_todo_item_for_current_state(entity:, entity_processing_state:, enrichment_type:, enrichment_state: nil)
        entity_id = entity.id
        entity_type = Conversions::ConvertToPolymorphicType.call(entity)
        Models::TodoItemState.create!(
          entity_id: entity_id,
          entity_type: entity_type,
          entity_processing_state: entity_processing_state,
          enrichment_type: enrichment_type,
          enrichment_state: enrichment_state
        )
      end
    end
    private_constant :TodoListCommands
  end
end
