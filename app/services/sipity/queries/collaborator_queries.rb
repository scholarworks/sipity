module Sipity
  module Queries
    # Queries
    # Queries
    module CollaboratorQueries
      def sip_collaborators_for(options = {})
        Models::Collaborator.includes(:sip).where(options.slice(:sip, :role))
      end
      module_function :sip_collaborators_for
      public :sip_collaborators_for

      def sip_collaborator_names_for(options = {})
        sip_collaborators_for(options).pluck(:name)
      end
      module_function :sip_collaborator_names_for
      public :sip_collaborator_names_for
    end
  end
end
