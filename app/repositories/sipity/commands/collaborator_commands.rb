module Sipity
  # :nodoc:
  module Commands
    # Commands
    module CollaboratorCommands
      # REVIEW: Consider moving these into the SipCommands
      module_function def create_collaborators_for_sip!(sip:, collaborators:)
        collaborators.each do |collaborator|
          collaborator.sip = sip
          collaborator.save!
        end
      end
      public :create_collaborators_for_sip!
    end
  end
end
