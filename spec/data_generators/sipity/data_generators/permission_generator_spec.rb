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

      it 'will grant strategy responsible to actor as the given role' do
        expect do
          expect do
            described_class.call(actors: user, role: role, strategy: strategy)
          end.to change { Models::Processing::StrategyRole.count }.by(1)
        end.to change { Models::Processing::StrategyResponsibility.count }.by(1)
      end

      it 'will grant entity responsiblity to actor as the given role' do
        expect do
          expect do
            expect do
              described_class.call(actors: user, role: role, strategy: strategy, entity: entity)
            end.to change { Models::Processing::StrategyRole.count }.by(1)
          end.to change { Models::Processing::EntitySpecificResponsibility.count }.by(1)
        end.to_not change { Models::Processing::StrategyResponsibility.count }
      end

      it 'will be idempotent' do
        builder = lambda do
          described_class.call(
            actors: user,
            role: role,
            entity: entity,
            strategy: strategy,
            strategy_state: strategy_state,
            action_names: action_name
          )
        end
        builder.call
        [:update_attribute, :update_attributes, :update_attributes!, :save, :save!, :update, :update!].each do |method_names|
          expect_any_instance_of(ActiveRecord::Base).to_not receive(method_names)
        end
        builder.call
      end

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
