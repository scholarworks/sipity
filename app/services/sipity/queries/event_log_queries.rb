module Sipity
  module Queries
    # Queries
    module EventLogQueries
      # @param [Hash] options for conditional querying of the event log.
      # @option options [User] :user; If given, what events were taken by the user
      # @option options [Entity] :entity; If given, what events happened to the entity.
      def sequence_of_events_for(options = {})
        Models::EventLog.where(options.slice(:entity, :user)).order(created_at: :desc)
      end
    end
  end
end
