module Sipity
  # :nodoc:
  module RepositoryMethods
    # Methods related to header creation
    module HeaderMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::HeaderQueries)
        base.send(:include, Commands::HeaderCommands)
      end
    end
  end
end
