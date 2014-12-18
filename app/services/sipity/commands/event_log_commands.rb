module Sipity
  module Commands
    # Commands
    module EventLogCommands
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
  end
end
