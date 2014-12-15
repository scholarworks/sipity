module Sipity
  module Repo
    # Methods that are helpful for querying the event log
    module EventLogMethods
      # @param [Hash] options for conditional querying of the event log.
      # @option options [User] :user; If given, what events were taken by the user
      # @option options [Entity] :entity; If given, what events happened to the entity.
      def sequence_of_events_for(options = {})
        Models::EventLog.where(options.slice(:entity, :user)).order(created_at: :desc)
      end
    end
  end
end
