module Sipity
  module Services
    # Service object that handles the business logic of granting permission.
    class RegisterActionTakenOnEntity
      include Conversions::ConvertToProcessingEntity
      include Conversions::ConvertToProcessingActor
      def self.call(entity:, action:, requested_by:)
        new(entity: entity, action: action, requested_by: requested_by).call
      end

      def initialize(entity:, action:, requested_by:)
        self.entity = entity
        self.action = action
        self.requesting_actor = requested_by
      end
      attr_reader :entity, :action, :requesting_actor

      delegate :strategy, to: :entity

      def call
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.create!(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_actor_id: requesting_actor.id,
          on_behalf_of_actor_id: requesting_actor.id
        )
      end

      private

      def entity=(entity_like_object)
        @entity = convert_to_processing_entity(entity_like_object)
      end

      def action=(object)
        @action = convert_to_processing_action(strategy, object)
      end

      def requesting_actor=(actor_like_object)
        @requesting_actor = convert_to_processing_actor(actor_like_object)
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
