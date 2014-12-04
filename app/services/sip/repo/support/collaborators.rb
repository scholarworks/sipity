module Sip
  module Repo
    module Support
      # Responsible for managing collaborators
      module Collaborators
        module_function

        def create!(header:, collaborators:)
          collaborators.each do |collaborator|
            collaborator.header = header
            collaborator.save!
          end
        end

        def for(options = {})
          Collaborator.where(options.slice(:header, :role))
        end
      end
    end
  end
end
