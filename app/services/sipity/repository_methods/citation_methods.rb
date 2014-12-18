module Sipity
  # :nodoc:
  module RepositoryMethods
    # Citation related methods
    module CitationMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::CitationQueries)
        base.send(:include, Commands::CitationCommands)
      end
    end
  end
end
