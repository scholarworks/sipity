require 'sipity/jobs'

module Sipity
  # :nodoc:
  module RepositoryMethods
    # DOI related methods
    module DoiMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::DoiQueries)
        base.send(:include, Commands::DoiCommands)
      end
    end
  end
end
