module Sipity
  # :nodoc:
  module RepositoryMethods
    # Responsible for coordination of creating and managing account placeholders.
    module CollaboratorMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Commands)
      end

      module Commands
        module_function

        # HACK: This is a command method
        def create_collaborators_for_header!(header:, collaborators:)
          collaborators.each do |collaborator|
            collaborator.header = header
            collaborator.save!
          end
        end
        public :create_collaborators_for_header!
      end

      module_function

      # HACK: This is a query method
      def header_collaborators_for(options = {})
        Models::Collaborator.includes(:header).where(options.slice(:header, :role))
      end
      public :header_collaborators_for

      # HACK: This is a query method
      def header_collaborator_names_for(options = {})
        header_collaborators_for(options).pluck(:name)
      end
      public :header_collaborator_names_for
    end
    # TODO: Restore `private_constant :CollaboratorMethods`
  end
end
