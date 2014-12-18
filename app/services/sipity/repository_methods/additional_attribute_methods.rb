module Sipity
  # :nodoc:
  module RepositoryMethods
    # Citation related methods
    module AdditionalAttributeMethods
      # FIXME: Rearrange repository to have commands and queries separate.
      #   This is an abomination. I would like to separate the concerns a bit
      #   better.
      extend ActiveSupport::Concern

      included do |base|
        base.send(:include, Queries::AdditionalAttributeQueries)
        base.send(:include, Commands::AdditionalAttributeCommands)
      end
    end
  end
end
