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
        @processing_state = begin
          case object
          when Models::Processing::StrategyState
            object
          when String, Symbol
            Models::Processing::StrategyState.find_or_create_by!(
              strategy_id: strategy.id, name: object
            )
          else
            fail ProcessingStrategyStateConversionError, { strategy_id: strategy_id, name: object }.inspect
          end
        end
      end
    end
  end
end
