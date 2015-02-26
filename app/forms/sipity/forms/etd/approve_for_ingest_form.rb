module Sipity
  module Forms
    module Etd
      # Responsible for submitting the final Grad School approval.
      class ApproveForIngestForm < ProcessingActionForm
        def initialize(attributes = {})
          super
          self.action = attributes.fetch(:processing_action_name) { default_processing_action_name }
        end

        attr_reader :action

        def processing_action_name
          action.name
        end

        private

        def save(repository:, requested_by:)
          super do
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
            repository.send_notification_for_entity_trigger(
              notification: "confirmation_of_approve_for_ingest", entity: work, acting_as: ['creating_user', 'etd_reviewer', 'advisor']
            )
          end
        end

        def enrichment_type
          self.class.to_s.demodulize.underscore.sub(/_form\Z/i, '')
        end
        alias_method :default_processing_action_name, :enrichment_type

        include Conversions::ConvertToProcessingAction
        def action=(value)
          @action = convert_to_processing_action(value, scope: to_processing_entity)
        end
      end
    end
  end
end
