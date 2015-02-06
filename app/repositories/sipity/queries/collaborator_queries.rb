module Sipity
  module Queries
    # Queries
    #
    # TODO: Remove module methods for these functions. I want them to be mixins
    #   instead of the existing singletons.
    module CollaboratorQueries
      def find_or_initialize_collaborators_by(work:, id:, &block)
        Models::Collaborator.find_or_initialize_by(work_id: work.id, id: id, &block)
      end
      module_function :find_or_initialize_collaborators_by
      public :find_or_initialize_collaborators_by

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
