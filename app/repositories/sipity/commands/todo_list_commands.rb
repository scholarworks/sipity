module Sipity
  # :nodoc:
  module Commands
    # Responsible for interaction with the todo list.
    module TodoListCommands
      def register_action_taken_on_entity(work:, enrichment_type:, requested_by:)
        Services::RegisterActionTakenOnEntity.call(entity: work, action: enrichment_type, requested_by: requested_by)
      end
    end
  end
end
