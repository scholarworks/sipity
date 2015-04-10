module Sipity
  module Forms
    module Etd
      # Responsible for exposing ability for someone to comment and request
      # changes to the work on behalf of someone else.
      class RequestChangeOnBehalfOfForm < Forms::StateAdvancingActionForm
        def initialize(options = {})
          super
          self.comment = options[:comment]
          self.on_behalf_of_collaborator_id = options[:on_behalf_of_collaborator_id]
        end

        attr_accessor :comment, :on_behalf_of_collaborator_id
        private(:comment=, :on_behalf_of_collaborator_id)

        validates :comment, presence: true
        validates :on_behalf_of_collaborator_id, presence: true

        private

        def save(requested_by:)
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
        end
      end
    end
  end
end
