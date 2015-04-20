module Sipity
  module Forms
    module Etd
      # Responsible for exposing ability for someone to comment and request
      # changes to the work on behalf of someone else.
      class RequestChangeOnBehalfOfForm < Forms::StateAdvancingActionForm
        def initialize(options = {})
          super
          self.comment = options[:comment]
          self.on_behalf_of_collaborator_extension = build_collaborator_extension
          self.on_behalf_of_collaborator_id = options[:on_behalf_of_collaborator_id]
        end

        delegate(
          :valid_on_behalf_of_collaborators,
          :on_behalf_of_collaborator,
          :on_behalf_of_collaborator_id,
          :on_behalf_of_collaborator_id=,
          :valid_on_behalf_of_collaborator_ids,
          to: :on_behalf_of_collaborator_extension
        )

        attr_accessor :comment
        private(:comment=, :on_behalf_of_collaborator_id=)

        validates :comment, presence: true
        validates :on_behalf_of_collaborator_id, presence: true, inclusion: { in: :valid_on_behalf_of_collaborator_ids }

        private

        def save(requested_by:)
          # TODO: Consider extracting common behavior to a service method (see AdvisorRequestsChangeForm#save)
          send_notification_for(processing_comment: record_processing_comment, requested_by: requested_by)
          register_action_taken(requested_by: requested_by)
          log_event(requested_by: requested_by)
          update_processing_state
        end

        def record_processing_comment
          repository.record_processing_comment(
            entity: work, commenter: on_behalf_of_collaborator, comment: comment, action: action
          )
        end

        def send_notification_for(processing_comment:, requested_by:)
          repository.deliver_notification_for(
            the_thing: processing_comment, scope: action, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
          )
        end

        def register_action_taken(requested_by:)
          repository.register_action_taken_on_entity(
            work: work, enrichment_type: enrichment_type, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
          )
        end

        def log_event(requested_by:)
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
        end

        def update_processing_state
          repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
        end

        attr_accessor :on_behalf_of_collaborator_extension

        def build_collaborator_extension
          Forms::ComposableElements::OnBehalfOfCollaborator.new(form: self, repository: repository)
        end
      end
    end
  end
end
