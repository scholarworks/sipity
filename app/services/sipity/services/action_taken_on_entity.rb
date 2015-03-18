module Sipity
  module Services
    # Service object that handles the business logic of granting permission.
    class ActionTakenOnEntity
      include Conversions::ConvertToProcessingEntity
      include Conversions::ConvertToProcessingActor
      def self.register(entity:, action:, requested_by:, on_behalf_of: requested_by)
        new(entity: entity, action: action, requested_by: requested_by, on_behalf_of: on_behalf_of).register
      end

      def initialize(entity:, action:, requested_by:, on_behalf_of: requested_by)
        self.entity = entity
        self.action = action
        self.requesting_actor = requested_by
        self.on_behalf_of_actor = on_behalf_of
      end
      attr_reader :entity, :action, :requesting_actor, :on_behalf_of_actor

      def register
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.create!(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_actor_id: requesting_actor.id,
          on_behalf_of_actor_id: on_behalf_of_actor.id
        )
      end

      private

      def entity=(entity_like_object)
        @entity = convert_to_processing_entity(entity_like_object)
      end

      include Conversions::ConvertToProcessingAction
      def action=(object)
        @action = convert_to_processing_action(object, scope: entity)
      end

      def requesting_actor=(actor_like_object)
        @requesting_actor = convert_to_processing_actor(actor_like_object)
      end

      def on_behalf_of_actor=(actor_like_object)
        @on_behalf_of_actor = convert_to_processing_actor(actor_like_object)
      end
    end
  end
end
