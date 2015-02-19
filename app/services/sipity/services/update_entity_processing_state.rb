module Sipity
  module Services
    # Service object that handles the business logic of updating an entity's
    # processing state.
    class UpdateEntityProcessingState
      include Conversions::ConvertToProcessingEntity
      def self.call(entity:, processing_state:)
        new(entity: entity, processing_state: processing_state).call
      end

      def initialize(entity:, processing_state:)
        self.entity = entity
        self.processing_state = processing_state
      end
      attr_reader :entity, :processing_state
      delegate :strategy, to: :entity

      def call
        entity.update!(strategy_state: processing_state)
      end

      private

      def entity=(object)
        @entity = convert_to_processing_entity(object)
      end

      def processing_state=(object)
        @processing_state = convert_to_processing_state(object)
      end

      def convert_to_processing_state(object)
        return object if object.is_a?(Models::Processing::StrategyState)
        if object.is_a?(String) || object.is_a?(Symbol)
          state = Models::Processing::StrategyState.where(strategy_id: strategy.id, name: object).first
          return state if state.present?
        end
        fail Exceptions::ProcessingStrategyStateConversionError, { strategy_id: strategy.id, name: object }.inspect
      end
    end
  end
end
