module Sipity
  module Forms
    module Etd
      # Responsible for exposing ability for someone to signoff on the work
      # on behalf of someone else.
      class SignoffOnBehalfOfForm < Forms::StateAdvancingAction
        def initialize(attributes = {})
          super
          @on_behalf_of_collaborator = attributes[:on_behalf_of_collaborator]
          @signoff_service = attributes.fetch(:signoff_service) { default_signoff_service }
        end
        attr_reader :on_behalf_of_collaborator
        attr_reader :signoff_service
        private :signoff_service

        validates :on_behalf_of_collaborator, presence: true, inclusion: { in: :valid_on_behalf_of_collaborators }

        def valid_on_behalf_of_collaborators
          repository.collaborators_that_can_advance_the_current_state_of(work: work)
        end

        def render(f:)
          f.input(:on_behalf_of_collaborator, collection: valid_on_behalf_of_collaborators, value_method: :id)
        end

        private

        def save(requested_by:)
          super do
            signoff_service.call(form: self, requested_by: requested_by, repository: repository)
          end
        end

        def default_signoff_service
          ->(*args) { }
        end
      end
    end
  end
end
