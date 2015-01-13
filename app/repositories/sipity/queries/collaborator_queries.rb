module Sipity
  module Queries
    # Queries
    # Queries
    module CollaboratorQueries
      def work_collaborators_for(options = {})
        Models::Collaborator.includes(:work).where(options.slice(:work, :role))
      end
      module_function :work_collaborators_for
      public :work_collaborators_for

      def work_collaborator_names_for(options = {})
        work_collaborators_for(options).pluck(:name)
      end
      module_function :work_collaborator_names_for
      public :work_collaborator_names_for
    end
  end
end
