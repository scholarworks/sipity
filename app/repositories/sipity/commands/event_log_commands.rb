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
      # @param [ActiveRecord::Base] requested_by
      # @param [String] event_name
      #
      # @return void
      #
      # @note This is both a module function and an instance function.
      # @see The underlying spec defines the behavior; Do not access
      def log_event!(entity:, requested_by:, event_name:)
        Models::EventLog.create!(
          entity: entity, user_id: requested_by.id, requested_by: requested_by, event_name: event_name,
          identifier_id: PowerConverter.convert_to_identifier_id(requested_by)
        )
      end
    end
  end
end
