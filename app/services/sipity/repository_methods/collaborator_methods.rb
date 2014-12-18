module Sipity
  # :nodoc:
  module RepositoryMethods
    # Responsible for coordination of creating and managing account placeholders.
    module CollaboratorMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Commands::CollaboratorCommands)
        base.send(:include, Queries::CollaboratorQueries)
      end

      # TODO: Restore `private_constant :CollaboratorMethods`
    end
  end
end
