require_relative '../composable_elements/on_behalf_of_collaborator'

module Sipity
  module Forms
    module Etd
      # Responsible for exposing ability for someone to signoff on the work
      # on behalf of someone else.
      class SignoffOnBehalfOfForm < Forms::StateAdvancingActionForm
        def initialize(attributes = {})
          super
          self.on_behalf_of_collaborator_extension = build_collaborator_extension
          self.on_behalf_of_collaborator_id = attributes[:on_behalf_of_collaborator_id]
          self.signoff_service = attributes.fetch(:signoff_service) { default_signoff_service }
        end

        validates :on_behalf_of_collaborator_id, presence: true, inclusion: { in: :valid_on_behalf_of_collaborator_ids }

        delegate(
          :valid_on_behalf_of_collaborators,
          :on_behalf_of_collaborator,
          :on_behalf_of_collaborator_id,
          :on_behalf_of_collaborator_id=,
          :valid_on_behalf_of_collaborator_ids,
          to: :on_behalf_of_collaborator_extension
        )

        private(:on_behalf_of_collaborator_id=)

        def render(f:)
          f.input(:on_behalf_of_collaborator_id, collection: valid_on_behalf_of_collaborators, value_method: :id)
        end

        private

        def save(requested_by:)
          register_the_actions(requested_by: requested_by)
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
          signoff_service.call(form: self, requested_by: requested_by, repository: repository)
          work
        end

        RELATED_ACTION_FOR_SIGNOFF = 'advisor_signoff'
        def register_the_actions(requested_by:)
          repository.register_action_taken_on_entity(
            work: work, enrichment_type: enrichment_type, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
          )
          @registered_action = repository.register_action_taken_on_entity(
            work: work, enrichment_type: RELATED_ACTION_FOR_SIGNOFF, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
          )
        end

        attr_accessor :on_behalf_of_collaborator_extension, :signoff_service

        def default_signoff_service
          Services::AdvisorSignsOff
        end

        def build_collaborator_extension
          Forms::ComposableElements::OnBehalfOfCollaborator.new(form: self, repository: repository)
        end
      end
    end
  end
end
