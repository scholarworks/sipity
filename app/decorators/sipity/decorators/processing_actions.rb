module Sipity
  module Decorators
    # For the given :user and :entity what are the available actions?
    class ProcessingActions
      def initialize(user:, entity:, repository: default_repository)
        @user = user
        @entity = entity
        @repository = repository
      end
      attr_reader :user, :entity, :repository
      private :repository

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
        end.fetch(key, [])
      end

      def processing_actions
        repository.scope_permitted_strategy_actions_available_for_current_state(user: user, entity: entity)
      end

      def default_repository
        QueryRepository.new
      end
    end
  end
end