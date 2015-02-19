module Sipity
  module Forms
    module Etd
      # Responsible for submitting the associated entity to the advisor
      # for signoff.
      class SubmitForAdvisorSignoffForm < ProcessingActionForm
        def initialize(attributes = {})
          super
          @action = attributes.fetch(:action)
        end

        attr_reader :action

        private

        def save(repository:, requested_by:)
          super do
            repository.update_processing_state!(entity: entity, to: action.resulting_strategy_state)
            repository.send_notification_for_entity_trigger(
              notification: "confirmation_of_entity_submitted_for_review", entity: entity, acting_as: 'creating_user'
            )
            repository.send_notification_for_entity_trigger(
              notification: "entity_ready_for_review", entity: entity, acting_as: ['etd_reviewer', 'advisor']
            )
          end
        end

        def enrichment_type
          self.class.to_s.demodulize.underscore.sub(/_form\Z/i, '')
        end
      end
    end
  end
end
