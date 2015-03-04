module Sipity
  module Forms
    module Etd
      # Responsible for capturing comments and forwarding them on to the
      # student.
      class GradSchoolRequestsChangeForm < Forms::StateAdvancingAction
        def initialize(attributes = {})
          super
          @comment = attributes[:comment]
        end

        attr_reader :comment
        validates :comment, presence: true

        # @param f SimpleFormBuilder
        #
        # @return String
        def render(f:)
          f.input(:comment, as: :text, autofocus: true)
        end

        private

        def save(requested_by:)
          super do
            repository.record_processing_comment(entity: work, commenter: requested_by, comment: comment, action: action)
            repository.send_notification_for_entity_trigger(
              notification: 'grad_school_requests_change',
              entity: work,
              acting_as: ['creating_user']
            )
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
          end
        end
      end
    end
  end
end
