module Sipity
  module Commands
    # Command methods to interact with the Processing module.
    module ProcessingCommands
      # Responsible for deleting all registered state changing actions for the
      # given entity and strategy state.
      #
      # @param entity an object that can be converted into a Sipity::Models::Processing::Entity
      # @param strategy_state an object that can be converted into a Sipity::Models::Processing::StrategyState
      # @return nil
      def destroy_existing_registered_state_changing_actions_for(entity:, strategy_state:)
        existing_registered_state_changing_actions_for(entity: entity, strategy_state: strategy_state).
          destroy_all
      end

      private

      # @todo Extract to processing queries? It is needed here.
      def existing_registered_state_changing_actions_for(entity:, strategy_state:)
        entity = Conversions::ConvertToProcessingEntity.call(entity)
        strategy_state = PowerConverter.convert(strategy_state, scope: entity.strategy, to: :strategy_state)

        registers = Models::Processing::EntityActionRegister.arel_table
        actions = Models::Processing::StrategyAction.arel_table
        state_actions = Models::Processing::StrategyStateAction.arel_table

        Models::Processing::EntityActionRegister.where(
          registers[:entity_id].eq(entity.id).and(
            registers[:strategy_action_id].in(
              actions.project(
                actions[:id]
              ).join(state_actions).on(
                actions[:id].eq(state_actions[:strategy_action_id])
              ).where(
                actions[:action_type].eq(Models::Processing::StrategyAction::STATE_ADVANCING_ACTION).and(
                  state_actions[:originating_strategy_state_id].eq(strategy_state.id)
                )
              )
            )
          )
        )
      end
    end
  end
end
