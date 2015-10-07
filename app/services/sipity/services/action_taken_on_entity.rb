require 'active_support/core_ext/array/wrap'

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

      # TODO: Subject and entity are redundant. Rename parameter to :subject to
      #   reflect the more ambiguous nature of the action's response.
      def initialize(entity:, action:, requested_by:, **keywords)
        self.subject = entity
        self.entity = entity
        self.action = action
        self.requested_by = requested_by
        self.on_behalf_of = keywords.fetch(:on_behalf_of) { self.requested_by }
        self.repository = keywords.fetch(:repository) { default_repository }
        self.processing_hooks = keywords.fetch(:processing_hooks) { default_processing_hooks }

        # TODO: Push this down to the database?
        self.also_register_as = keywords.fetch(:also_register_as) { [] }
      end
      attr_reader :entity, :action, :requested_by, :on_behalf_of, :also_register_as, :subject

      def register
        log_the_action
        registered_action = register_action_on_entity(action: action)
        add_actions_that_should_also_be_registered
        deliver_notifications_for(registered_action: registered_action)
      end

      def unregister
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.where(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_identifier_id: requested_by.identifier_id,
          on_behalf_of_identifier_id: on_behalf_of.identifier_id
        ).destroy_all
      end

      private

      def add_actions_that_should_also_be_registered
        also_register_as.each { |action| register_action_on_entity(action: action) }
      end

      def register_action_on_entity(action:)
        processing_hooks.call(
          action: action, requested_by: requested_by, on_behalf_of: on_behalf_of, entity: entity, repository: repository
        )
        create_entity_action_registry_entry!(action: action)
      end

      include Conversions::ConvertToPolymorphicType
      def create_entity_action_registry_entry!(action:)
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.create!(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_identifier_id: requested_by.identifier_id,
          on_behalf_of_identifier_id: on_behalf_of.identifier_id,
          subject_id: subject.id,
          subject_type: convert_to_polymorphic_type(subject)
        )
      end

      def log_the_action
        # TODO: This is a cheat, in that I am assuming the request actor is a user.
        repository.log_event!(entity: entity, requested_by: requested_by, event_name: event_name)
      end

      def deliver_notifications_for(registered_action:)
        repository.deliver_notification_for(
          scope: action, the_thing: registered_action, requested_by: requested_by, on_behalf_of: on_behalf_of
        )
      end

      def event_name
        "#{action.name}/submit"
      end

      attr_accessor :repository

      def default_repository
        CommandRepository.new
      end

      attr_accessor :processing_hooks
      def default_processing_hooks
        ProcessingHooks
      end

      include Conversions::ConvertToProcessingEntity
      def entity=(entity_like_object)
        @entity = convert_to_processing_entity(entity_like_object)
      end

      def subject=(input)
        # Guard!
        convert_to_polymorphic_type(input)
        @subject = input
      end

      include Conversions::ConvertToProcessingAction
      def action=(object)
        @action = convert_to_processing_action(object, scope: entity)
      end

      def also_register_as=(input)
        @also_register_as = Array.wrap(input).map { |an_action| convert_to_processing_action(an_action, scope: entity) }
      end

      def requested_by=(input)
        @requested_by = PowerConverter.convert(input, to: :identifiable_agent)
      end

      def on_behalf_of=(input)
        @on_behalf_of = PowerConverter.convert(input, to: :identifiable_agent)
      end
    end
  end
end
