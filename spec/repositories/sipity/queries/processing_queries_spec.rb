require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe ProcessingQueries, type: :isolated_repository_module do
      include Conversions::ConvertToPolymorphicType
      let(:user) { User.new(id: 1) }
      let(:group) { Models::Group.new(id: 2) }
      let(:role) { Models::Role.new(id: 3) }
      let(:strategy) { Models::Processing::Strategy.new(id: 4) }
      let(:entity) { Models::Processing::Entity.new(id: 5, strategy_id: strategy.id) }
      let(:user_processing_actor) do
        Models::Processing::Actor.create!(proxy_for_id: user.id, proxy_for_type: convert_to_polymorphic_type(user))
      end
      let(:group_processing_actor) do
        Models::Processing::Actor.create!(proxy_for_id: group.id, proxy_for_type: convert_to_polymorphic_type(group))
      end
      let(:strategy_role) { Models::Processing::StrategyRole.create!(role_id: role.id, strategy_id: strategy.id) }
      let(:user_strategy_responsibility) do
        Models::Processing::StrategyResponsibility.create!(strategy_role_id: strategy_role.id, actor_id: user_processing_actor.id)
      end
      let(:entity_specific_responsibility) do
        Models::Processing::EntitySpecificResponsibility.create!(
          strategy_role_id: strategy_role.id, actor_id: user_processing_actor.id, entity_id: entity.id
        )
      end
      let(:action) { Models::Processing::StrategyAction.new(id: 6, strategy_id: strategy.id, name: 'complete') }
      let(:originating_state) { Models::Processing::StrategyState.new(id: 7, strategy_id: strategy.id, name: 'new') }
      let(:resulting_state) { Models::Processing::StrategyState.new(id: 8, strategy_id: strategy.id, name: 'done') }
      let(:strategy_event) do
        Models::Processing::StrategyEvent.create!(
          id: 9, originating_strategy_state_id: originating_state.id, resulting_strategy_state_id: resulting_state.id,
          strategy_action_id: action.id
        )
      end
      let(:event_permission) do
        Models::Processing::StrategyEventPermission.create!(
          strategy_role_id: strategy_role.id, strategy_event_id: strategy_event.id
        )
      end
      context '#available_processing_events_for' do

      end

      context '#scope_processing_strategy_roles_for_user_and_entity' do
        subject { test_repository.scope_processing_strategy_roles_for_user_and_entity(user: user, entity: entity) }
        before { entity.strategy = strategy }
        it "will include the strategy specific roles for the given user" do
          user_processing_actor
          user_strategy_responsibility
          expect(subject).to eq([strategy_role])
        end
        it "will include the entity specific specific roles for the given user" do
          user_processing_actor
          entity_specific_responsibility
          expect(subject).to eq([strategy_role])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_processing_actors_for' do
        subject { test_repository.scope_processing_actors_for(user: user) }
        it 'will return an array of both user ' do
          user_processing_actor
          group_processing_actor
          Models::GroupMembership.create(user_id: user.id, group_id: group.id)
          expect(subject).to eq([user_processing_actor, group_processing_actor])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_processing_strategy_roles_for' do
        subject { test_repository.scope_processing_strategy_roles_for(user: user, strategy: strategy) }
        it "will include the associated strategy roles for the given user" do
          user_processing_actor
          user_strategy_responsibility
          expect(subject).to eq([strategy_role])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_entity_specific_processing_strategy_roles' do
        subject { test_repository.scope_entity_specific_processing_strategy_roles(user: user, entity: entity) }
        it "will include the associated strategy roles for the given user" do
          user_processing_actor
          entity_specific_responsibility
          expect(subject).to eq([strategy_role])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_permitted_entity_strategy_events' do
        subject { test_repository.scope_permitted_entity_strategy_events(user: user, entity: entity) }
        before { entity.strategy = strategy }
        it "will include permitted strategy_events" do
          user_processing_actor
          entity_specific_responsibility
          event_permission
          expect(subject).to eq([event_permission.strategy_event])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end
    end
  end
end
