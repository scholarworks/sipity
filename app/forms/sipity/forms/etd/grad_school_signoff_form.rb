module Sipity
  module Forms
    module Etd
      # Responsible for submitting the final Grad School approval.
      class GradSchoolSignoffForm < Forms::StateAdvancingAction
        private

        def save(requested_by:)
          super do
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
            repository.send_notification_for_entity_trigger(
              notification: "confirmation_of_grad_school_signoff", entity: work, acting_as: ['creating_user', 'etd_reviewer', 'advisor']
            )
          end
        end
      end
    end
  end
end
