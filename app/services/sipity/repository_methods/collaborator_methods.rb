module Sipity
  # :nodoc:
  module RepositoryMethods
    # Responsible for coordination of creating and managing account placeholders.
    module CollaboratorMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Commands)
        base.send(:include, Queries)
      end

      # Commands
      module Commands
        module_function

        def create_collaborators_for_header!(header:, collaborators:)
          collaborators.each do |collaborator|
            collaborator.header = header
            collaborator.save!
          end
        end
        public :create_collaborators_for_header!
      end

      # Queries
      module Queries

        def header_collaborators_for(options = {})
          Models::Collaborator.includes(:header).where(options.slice(:header, :role))
        end
        module_function :header_collaborators_for
        public :header_collaborators_for

        def header_collaborator_names_for(options = {})
          header_collaborators_for(options).pluck(:name)
        end
        module_function :header_collaborator_names_for
        public :header_collaborator_names_for
      end
    end
    # TODO: Restore `private_constant :CollaboratorMethods`
  end
end
