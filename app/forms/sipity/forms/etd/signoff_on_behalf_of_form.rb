module Sipity
  module Forms
    module Etd
      # Responsible for exposing approval on behalf of.
      class SignoffOnBehalfOfForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @on_behalf_of_collaborator = attributes[:on_behalf_of_collaborator]
          @signoff_service = attributes.fetch(:signoff_service) { default_signoff_service }
        end
        attr_reader :on_behalf_of_collaborator
        validates :on_behalf_of_collaborator, presence: true, inclusion: { in: :valid_on_behalf_of_collaborators }

        private

        def valid_on_behalf_of_collaborators
          ['bob']
        end

        def default_signoff_service
          ->(*args) { }
        end
      end
    end
  end
end
