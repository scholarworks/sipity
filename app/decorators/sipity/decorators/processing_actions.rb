module Sipity
  module Decorators
    # For the given :user and :entity what are the available actions?
    class ProcessingActions
      def initialize(user:, entity:, repository: default_repository, action_builder: default_action_builder)
        @user = user
        @entity = entity
        @repository = repository
        @action_builder = action_builder
      end
      attr_reader :user, :entity, :repository, :action_builder
      private :repository, :action_builder

      def enrichment_actions
        fetch(Models::Processing::StrategyAction::ENRICHMENT_ACTION)
      end

      def resourceful_actions
        fetch(Models::Processing::StrategyAction::RESOURCEFUL_ACTION)
      end

      def state_advancing_actions
        fetch(Models::Processing::StrategyAction::STATE_ADVANCING_ACTION)
      end

      private

      def fetch(key)
        @data_store ||= processing_actions.each_with_object({}) do |action, mem|
          mem[action.action_type] ||= []
          mem[action.action_type] << action
          mem
        end
        @data_store.fetch(key, [])
      end

      def processing_actions
        repository.scope_permitted_entity_strategy_actions_for_current_state(user: user, entity: entity).map do |action|
          action_builder.call(
            action: action, user: user, entity: entity,
            is_completed: completed_action_ids.include?(action.id),
            is_a_prerequisite: action_ids_that_are_prerequisites.include?(action.id)
          )
        end
      end

      def action_ids_that_are_prerequisites
        @action_ids_that_are_prerequisites ||= repository.scope_strategy_actions_that_are_prerequisites(entity: entity).pluck(:id)
      end

      def completed_action_ids
        @completed_action_ids ||= repository.scope_statetegy_actions_that_have_occurred(entity: entity).pluck(:id)
      end

      def default_repository
        QueryRepository.new
      end

      def default_action_builder
        ActionDecorator.method(:build)
      end
    end
  end
end
