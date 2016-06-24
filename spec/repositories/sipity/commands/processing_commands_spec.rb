require "rails_helper"

module Sipity
  module Commands
    RSpec.describe ProcessingCommands, type: :isolated_repository_module do
      let(:strategy) { Models::Processing::Strategy.new(id: 3) }
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy: strategy) }
      let(:strategy_state) { Models::Processing::StrategyState.new(id: 2, strategy_id: strategy.id) }
      let(:strategy_action) do
        Models::Processing::StrategyAction.create!(
          strategy_id: strategy.id,
          resulting_strategy_state_id: 4,
          action_type: Models::Processing::StrategyAction::STATE_ADVANCING_ACTION,
          name: 'action'
        )
      end
      let(:strategy_state_action) do
        Models::Processing::StrategyStateAction.create!(
          strategy_action_id: strategy_action.id,
          originating_strategy_state_id: strategy_state.id
        )
      end
      before do
        strategy_action
        strategy_state_action
        Models::Processing::EntityActionRegister.create!(
          entity_id: entity.id,
          strategy_action_id: strategy_action.id,
          subject_id: entity.id,
          subject_type: "Sipity::Models::Processing::Entity",
          requested_by_actor_id: 999,
          on_behalf_of_actor_id: 999
        )
      end
      context '#destroy_existing_registered_state_changing_actions_for' do
        it 'will delete registered state advancing actions that are available for the given strategy state' do
          expect do
            test_repository.destroy_existing_registered_state_changing_actions_for(entity: entity, strategy_state: strategy_state)
          end.to change { Models::Processing::EntityActionRegister.count }.by(-1)
        end
      end
    end
  end
end
