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
      def register_action_taken_on_entity(work:, enrichment_type:)
        Services::RegisterActionTakenOnEntity.call(entity: work, action: enrichment_type)
      end
    end
  end
end
