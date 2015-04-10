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

        attr_accessor :on_behalf_of_collaborator_extension

        def save(requested_by:)
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
        end

        def build_collaborator_extension
          Forms::ComposableElements::OnBehalfOfCollaborator.new(form: self, repository: repository)
        end
      end
    end
  end
end
