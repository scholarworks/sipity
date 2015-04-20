module Sipity
  module Services
    # Service object that handles the business logic of updating an entity's
    # processing state.
    class UpdateEntityProcessingState
      def self.call(entity:, processing_state:, **collaborators)
        new(entity: entity, processing_state: processing_state, **collaborators).call
      end

      def initialize(entity:, processing_state:, **collaborators)
        self.entity = entity
        self.processing_state = processing_state
        self.repository = collaborators.fetch(:repository) { default_repository }
      end
      attr_reader :entity, :processing_state
      delegate :strategy, to: :entity

      attr_accessor :repository
      private :repository=, :repository

      def call
        mark_as_stale_existing_comments_for_new_processing_state
        destroy_existing_registered_state_changing_actions_for_new_processing_state
        transition_entity_to_new_processing_state
        deliver_emails_for_transitioning_into_new_processing_state
      end

      private

      def mark_as_stale_existing_comments_for_new_processing_state
        # REVIEW: Should the scope be migrated into a repository method?
        Models::Processing::Comment.where(entity_id: entity.id, originating_strategy_state_id: processing_state.id).update_all(stale: true)
      end

      def destroy_existing_registered_state_changing_actions_for_new_processing_state
        repository.destroy_existing_registered_state_changing_actions_for(entity: entity, strategy_state: processing_state)
      end

      def transition_entity_to_new_processing_state
        entity.update!(strategy_state: processing_state)
      end

      def deliver_emails_for_transitioning_into_new_processing_state
        repository.
      end

      include Conversions::ConvertToProcessingEntity
      def entity=(object)
        @entity = convert_to_processing_entity(object)
      end

      def processing_state=(object)
        @processing_state = PowerConverter.convert(object, scope: strategy, to: :strategy_state)
      end

      def default_repository
        CommandRepository.new
      end
    end
  end
end
