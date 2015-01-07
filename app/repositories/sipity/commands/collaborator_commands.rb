module Sipity
  # :nodoc:
  module Commands
    # Commands
    module CollaboratorCommands
      module_function

      # REVIEW: Consider moving these into the SipCommands
      def create_collaborators_for_sip!(sip:, collaborators:)
        collaborators.each do |collaborator|
          collaborator.sip = sip
          collaborator.save!
        end
      end
      public :create_collaborators_for_sip!
    end
  end
end
