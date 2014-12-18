module Sipity
  # :nodoc:
  module RepositoryMethods
    # Methods that are helpful for querying the event log
    module EventLogMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::EventLogQueries)
        base.send(:include, Commands::EventLogCommands)
      end
    end
  end
end
