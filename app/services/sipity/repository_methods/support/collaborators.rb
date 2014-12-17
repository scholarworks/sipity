module Sipity
  module RepositoryMethods
    module Support
      # Responsible for managing collaborators
      module Collaborators
        module_function

        # def create!(header:, collaborators:)
        #   ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
        #   CollaboratorMethods.create_collaborators_for_header!(header: header, collaborators: collaborators)
        # end

        def for(options = {})
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          CollaboratorMethods.header_collaborators_for(options)
        end

        def names_for(options = {})
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          CollaboratorMethods.header_collaborator_names_for(options)
        end
      end
    end
  end
end
