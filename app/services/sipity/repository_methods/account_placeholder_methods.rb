module Sipity
  # :nodoc:
  module RepositoryMethods
    # Responsible for coordination of creating and managing account placeholders.
    module AccountPlaceholderMethods
      # FIXME: Rearrange repository to have commands and queries separate.
      #   This is an abomination. I would like to separate the concerns a bit
      #   better.
      extend ActiveSupport::Concern

      included do |base|
        base.send(:include, Queries::AccountPlaceholderQueries)
        base.send(:include, Commands::AccountPlaceholderCommands)
      end
    end
  end
end
