module Sipity
  module Queries
    # Queries
    # Queries
    module CollaboratorQueries
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
end
