require 'rails_helper'

module Sipity
  module DataGenerators
    RSpec.describe PermissionGenerator do
      let(:user) { Sipity::Factories.create_user }
      let(:role) { 'creating_user' }
      let(:strategy) { Models::Processing::Strategy.create!(name: 'strategy') }
      let(:strategy_state) { strategy.initial_strategy_state }
      let(:entity) do
        Models::Processing::Entity.create!(proxy_for_id: '1', proxy_for_type: 'User', strategy: strategy, strategy_state: strategy_state)
      end
      let(:another_entity) do
        Models::Processing::Entity.create!(proxy_for_id: '2', proxy_for_type: 'User', strategy: strategy, strategy_state: strategy_state)
      end
      let(:action_name) { 'show' }

      it 'will build the entity level permissions if an entity is specified' do
        described_class.call(
          actors: user,
          role: role,
          entity: entity,
          strategy: strategy,
          strategy_state: strategy_state,
          action_names: action_name
        )
        permission_to_action = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: entity, action_to_authorize: action_name
        )
        expect(permission_to_action).to be_truthy

        permission_to_another_entity_action = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: another_entity, action_to_authorize: action_name
        )
        expect(permission_to_another_entity_action).to be_falsey
      end

      it 'will build the strategy level permissions if no entity is given' do
        described_class.call(
          actors: user,
          role: role,
          strategy: strategy,
          strategy_state: strategy_state,
          action_names: action_name
        )
        permission_to_action = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: entity, action_to_authorize: action_name
        )
        expect(permission_to_action).to be_truthy

        permission_to_another_entity_action = Policies::Processing::ProcessingEntityPolicy.call(
          user: user, entity: another_entity, action_to_authorize: action_name
        )
        expect(permission_to_another_entity_action).to be_truthy
      end
    end
  end
end
