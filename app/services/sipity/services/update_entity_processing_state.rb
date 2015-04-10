module Sipity
  module Services
    # Service object that handles the business logic of updating an entity's
    # processing state.
    class UpdateEntityProcessingState
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
        mark_as_stale_existing_comments_for_new_processing_state
        transition_entity_to_new_processing_state
      end

      private

      def mark_as_stale_existing_comments_for_new_processing_state
        Models::Processing::Comment.where(entity_id: entity.id, originating_strategy_state_id: processing_state.id).update_all(stale: true)
      end

      def transition_entity_to_new_processing_state
        entity.update!(strategy_state: processing_state)
      end

      include Conversions::ConvertToProcessingEntity
      def entity=(object)
        @entity = convert_to_processing_entity(object)
      end

      def processing_state=(object)
        @processing_state = PowerConverter.convert(object, scope: strategy, to: :strategy_state)
      end
    end
  end
end
