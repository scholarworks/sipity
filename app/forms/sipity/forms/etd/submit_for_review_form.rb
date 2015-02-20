module Sipity
  module Forms
    module Etd
      # Responsible for submitting the associated entity to the advisor
      # for signoff.
      class SubmitForReviewForm < ProcessingActionForm
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
              notification: "confirmation_of_entity_submitted_for_review", entity: work, acting_as: 'creating_user'
            )
            repository.send_notification_for_entity_trigger(
              notification: "entity_ready_for_review", entity: work, acting_as: ['etd_reviewer', 'advisor']
            )
          end
        end

        def enrichment_type
          self.class.to_s.demodulize.underscore.sub(/_form\Z/i, '')
        end
        alias_method :default_processing_action_name, :enrichment_type

        def action=(value)
          @action = convert_to_processing_action(value)
        end

        # HACK: In a perfect world I would not need to convert the action;
        # However to comply with the previous interface, this needs to be done.work_event_triggers_spec.rb
        def convert_to_processing_action(object)
          if object.is_a?(Models::Processing::StrategyAction)
            return object if object.strategy_id == strategy_id
          else
            strategy_action = Models::Processing::StrategyAction.find_by(strategy_id: strategy_id, name: object.to_s)
            return strategy_action if strategy_action.present?
          end
          fail Exceptions::ProcessingStrategyActionConversionError, { strategy_id: strategy_id, name: object }.inspect
        end
      end
    end
  end
end
