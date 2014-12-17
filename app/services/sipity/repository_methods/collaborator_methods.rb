module Sipity
  # :nodoc:
  module RepositoryMethods
    # Responsible for coordination of creating and managing account placeholders.
    module CollaboratorMethods
      module_function

      def create_collaborators_for_header!(header:, collaborators:)
        collaborators.each do |collaborator|
          collaborator.header = header
          collaborator.save!
        end
      end
      public :create_collaborators_for_header!

      def header_collaborators_for(options = {})
        Models::Collaborator.includes(:header).where(options.slice(:header, :role))
      end
      public :header_collaborators_for

      def header_collaborator_names_for(options = {})
        header_collaborators_for(options).pluck(:name)
      end
      public :header_collaborator_names_for
    end
    private_constant :CollaboratorMethods
  end
end
