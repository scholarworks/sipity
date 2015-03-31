module Sipity
  module Decorators
    # For the given :user and :entity what are the available actions?
    class ProcessingActions
      def initialize(user:, entity:, repository: default_repository, action_decorator: default_action_decorator)
        @user = user
        @entity = entity
        @repository = repository
        @action_decorator = action_decorator
      end
      attr_reader :user, :entity, :repository, :action_decorator
      private :repository, :action_decorator

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
        repository.scope_permitted_entity_strategy_actions_for_current_state(user: user, entity: entity).each_with_object([]) do |action, mem|
          with_decorated_action(action) { |decorated| mem << decorated }
          mem
        end
      end

      def with_decorated_action(action)
        decorated_action = action_decorator.call(
          action: action, user: user, entity: entity,
          is_complete: completed_action_ids.include?(action.id),
          is_a_prerequisite: action_ids_that_are_prerequisites.include?(action.id)
        )
        yield(decorated_action)
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

      def default_action_decorator
        ActionDecorator.method(:build)
      end
    end
  end
end
