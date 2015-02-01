require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe ProcessingQueries, type: :isolated_repository_module do
      let(:user) { User.new(id: 1) }
      let(:group) { Models::Group.new(id: 2) }
      let(:role) { Models::Role.new(id: 3) }
      let(:strategy) { Models::Processing::Strategy.new(id: 4) }
      let(:entity) { Models::Processing::Entity.new(id: 5, strategy_id: strategy.id) }
      let(:user_processing_actor) do
        Models::Processing::Actor.create!(proxy_for_id: user.id, proxy_for_type: Conversions::ConvertToPolymorphicType.call(user))
      end
      let(:group_processing_actor) do
        Models::Processing::Actor.create!(proxy_for_id: group.id, proxy_for_type: Conversions::ConvertToPolymorphicType.call(group))
      end
      let(:strategy_role) do
        Models::Processing::StrategyRole.create!(role_id: role.id, strategy_id: strategy.id)
      end
      let(:user_strategy_responsibility) do
        Models::Processing::StrategyResponsibility.create!(strategy_role_id: strategy_role.id, actor_id: user_processing_actor.id)
      end
      let(:entity_specific_responsibility) do
        Models::Processing::EntitySpecificResponsibility.create!(
          strategy_role_id: strategy_role.id, actor_id: user_processing_actor.id, entity_id: entity.id
        )
      end
      context '#available_processing_events_for' do

      end

      context '#scope_processing_actors_for' do
        before do
          user_processing_actor
          group_processing_actor
          Models::GroupMembership.create(user_id: user.id, group_id: group.id)
        end

        it 'will return an array of both user ' do
          expect(test_repository.scope_processing_actors_for(user: user)).
            to eq([user_processing_actor, group_processing_actor])
        end
      end

      context '#scope_processing_strategy_roles_for' do
        before do
          user_processing_actor
          user_strategy_responsibility
        end
        it "will include the associated strategy roles for the given user" do
          expect(test_repository.scope_processing_strategy_roles_for(user: user, strategy: strategy)).
            to eq([strategy_role])
        end
      end

      context '#scope_custom_processing_strategy_roles_for_user_and_entity' do
        before do
          user_processing_actor
          entity_specific_responsibility
        end
        it "will include the associated strategy roles for the given user" do
          expect(test_repository.scope_custom_processing_strategy_roles_for_user_and_entity(user: user, entity: entity)).
            to eq([strategy_role])
        end
      end
    end
  end
end
