module Sipity
  module Services
    # Service object that handles the business logic of granting permission.
    class RegisterActionTakenOnEntity
      include Conversions::ConvertToProcessingEntity
      def self.call(entity:, action:)
        new(entity: entity, action: action).call
      end

      def initialize(entity:, action:)
        self.entity = entity
        self.action = action
      end
      attr_reader :entity, :action

      delegate :strategy, to: :entity

      def call
        Models::Processing::EntityActionRegister.create!(strategy_action_id: action.id, entity_id: entity.id)
      end

      private

      def entity=(entity_like_object)
        @entity = convert_to_processing_entity(entity_like_object)
      end

      def action=(object)
        @action = convert_to_processing_action(strategy, object)
      end

      def convert_to_processing_action(strategy, object)
        if object.is_a?(Models::Processing::StrategyAction)
          return object if object.strategy_id == strategy.id
        else
          strategy_action = Models::Processing::StrategyAction.where(strategy_id: strategy.id, name: object.to_s).first
          return strategy_action if strategy_action.present?
        end
        fail Exceptions::ProcessingStrategyActionConversionError, { strategy_id: strategy.id, name: object }.inspect
      end
    end
  end
end
