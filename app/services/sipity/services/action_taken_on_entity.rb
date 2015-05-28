module Sipity
  module Services
    # Service object that handles the business logic of granting permission.
    class ActionTakenOnEntity
      def self.register(**keywords)
        new(**keywords).register
      end

      def self.unregister(**keywords)
        new(**keywords).unregister
      end

      def initialize(entity:, action:, requested_by:, **keywords)
        self.entity = entity
        self.action = action
        self.requesting_actor = requested_by
        self.on_behalf_of_actor = keywords.fetch(:on_behalf_of) { requesting_actor }
        self.repository = keywords.fetch(:repository) { default_repository }
      end
      attr_reader :entity, :action, :requesting_actor, :on_behalf_of_actor

      def register
        add_entry_to_the_entity_action_regsistry
        log_the_action
      end

      def unregister
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.where(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_actor_id: requesting_actor.id,
          on_behalf_of_actor_id: on_behalf_of_actor.id
        ).destroy_all
      end

      private

      def add_entry_to_the_entity_action_regsistry
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.create!(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_actor_id: requesting_actor.id,
          on_behalf_of_actor_id: on_behalf_of_actor.id
        )
      end

      def log_the_action
        # TODO: This is a cheat, in that I am assuming the request actor is a user.
        repository.log_event!(entity: entity, user: requesting_actor.proxy_for, event_name: event_name)
      end

      def event_name
        "#{action.name}/submit"
      end

      attr_accessor :repository

      def default_repository
        CommandRepository.new
      end

      include Conversions::ConvertToProcessingEntity
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

      include Conversions::ConvertToProcessingActor
      def on_behalf_of_actor=(actor_like_object)
        @on_behalf_of_actor = convert_to_processing_actor(actor_like_object)
      end
    end
  end
end
