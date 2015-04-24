module Sipity
  module Decorators
    # For the given :user and :entity what are the available actions?
    #
    # These actions are grouped by the StrategyAction type.
    class ProcessingActions
      def initialize(user:, entity:, repository: default_repository, action_decorator: default_action_decorator)
        self.user = user
        self.entity = entity
        self.repository = repository
        self.action_decorator = action_decorator
      end
      attr_accessor :user, :entity, :repository, :action_decorator
      private :repository, :action_decorator, :user=, :entity=, :repository=, :action_decorator=

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
        @data_store ||= build_data_store
        @data_store.fetch(key, [])
      end

      def processing_actions
        repository.scope_permitted_entity_strategy_actions_for_current_state(user: user, entity: entity)
      end

      def build_data_store
        processing_actions.each_with_object({}) do |action, mem|
          with_decorated_action(action) do |decorated_action|
            mem[decorated_action.action_type] ||= []
            mem[decorated_action.action_type] << decorated_action
          end
          mem
        end
      end

      def with_decorated_action(action)
        # TODO: Can the query be built such that is_complete and is_a_prerequisite are
        # already part of the returned data structure? Yes.
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
