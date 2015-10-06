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
      # @param [#to_identifier_id] requested_by
      # @param [String] event_name
      #
      # @return void
      #
      # @note This is both a module function and an instance function.
      # @see The underlying spec defines the behavior; Do not access
      def log_event!(entity:, requested_by:, event_name:)
        requested_by_identifier_id = PowerConverter.convert_to_identifier_id(requested_by)
        if entity.is_a?(ActiveRecord::Base)
          Models::EventLog.create!(entity: entity, event_name: event_name, identifier_id: requested_by_identifier_id)
        else
          identifiable_agent = PowerConverter.convert(entity, to: :identifiable_agent)
          Models::EventLog.create!(
            entity_id: identifiable_agent.identifier_id, entity_type: Sipity::Models::IdentifiableAgent, event_name: event_name,
            identifier_id: requested_by_identifier_id
          )
        end
      end
    end
  end
end
