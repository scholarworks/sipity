module Sipity
  # :nodoc:
  module Commands
    # Commands
    module EventLogCommands
      # Responsible for recording that the given :user has triggered the given
      # :event_name on the given :entity.
      #
      # @param [Entity] entity - The entity on which the given user has performed the
      #   named event
      # @param [User] user
      # @param [String] event_name
      #
      # @return void
      #
      # @note This is both a module function and an instance function.
      # @see The underlying spec defines the behavior; Do not access
      def log_event!(entity:, user:, event_name:)
        # TODO: Consider switching this to polymorphic in nature
        Models::EventLog.create!(entity: entity, user_id: user.id, event_name: event_name)
      end
    end
  end
end
