module Sipity
  module RepositoryMethods
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
          Models::Collaborator.includes(:header).where(options.slice(:header, :role))
        end

        def names_for(options = {})
          self.for(options).pluck(:name)
        end
      end
    end
  end
end
