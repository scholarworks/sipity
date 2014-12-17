module Sipity
  module RepositoryMethods
    # Methods that are helpful for querying the event log
    module EventLogMethods
      # @param [Hash] options for conditional querying of the event log.
      # @option options [User] :user; If given, what events were taken by the user
      # @option options [Entity] :entity; If given, what events happened to the entity.
      def sequence_of_events_for(options = {})
        Models::EventLog.where(options.slice(:entity, :user)).order(created_at: :desc)
      end

      # @note This is both a module function and an instance function.
      # @see The underlying spec defines the behavior; Do not access
      def log_event!(entity:, user:, event_name:)
        Models::EventLog.create!(entity: entity, user: user, event_name: event_name)
      end

      # TODO: Make this module a private constant. This means moving the modules
      #   into the same name space as where they are included. I'm trying to
      #   make sure that the repository layer remains a unified interface and
      #   not exposing module functions beyond the repository layer.
      module_function :log_event!
      public :log_event!
    end
    private_constant :EventLogMethods
  end
end
