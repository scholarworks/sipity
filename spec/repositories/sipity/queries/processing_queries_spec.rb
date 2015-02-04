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
      let(:entity) { Models::Processing::Entity.new(id: 5, strategy_id: strategy.id, strategy_state_id: originating_state.id) }
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
      let(:event) { Models::Processing::StrategyEvent.new(id: 6, strategy_id: strategy.id, name: 'complete') }
      let(:originating_state) { Models::Processing::StrategyState.new(id: 7, strategy_id: strategy.id, name: 'new') }
      let(:resulting_state) { Models::Processing::StrategyState.new(id: 8, strategy_id: strategy.id, name: 'done') }
      let(:strategy_action) do
        Models::Processing::StrategyAction.create!(originating_strategy_state_id: originating_state.id, strategy_event_id: event.id)
      end
      let(:action_permission) do
        Models::Processing::StrategyActionPermission.create!(
          strategy_role_id: strategy_role.id, strategy_action_id: strategy_action.id
        )
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

      context '#scope_permitted_entity_strategy_actions' do
        subject { test_repository.scope_permitted_entity_strategy_actions(user: user, entity: entity) }
        before { entity.strategy = strategy }
        it "will include permitted strategy_actions" do
          user_processing_actor
          entity_specific_responsibility
          action_permission
          expect(subject).to eq([action_permission.strategy_action])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_permitted_entity_strategy_actions_for_current_state' do
        subject { test_repository.scope_permitted_entity_strategy_actions_for_current_state(user: user, entity: entity) }
        let!(:unavailable_state_event) do
          Models::Processing::StrategyAction.create!(originating_strategy_state_id: resulting_state.id, strategy_event_id: event.id)
        end
        before do
          entity.strategy = strategy
          entity.strategy_state = originating_state
        end
        it "will include permitted strategy_actions" do
          user_processing_actor
          entity_specific_responsibility
          action_permission
          expect(subject).to eq([action_permission.strategy_action])
        end
        it "will skip those not in the correct state" do
          user_processing_actor
          entity_specific_responsibility
          action_permission
          entity.strategy_state = resulting_state
          expect(subject).to eq([])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_strategy_events_with_prerequisites' do
        subject { test_repository.scope_strategy_events_with_prerequisites(entity: entity) }
        let(:guarded_event) { Models::Processing::StrategyEvent.create!(strategy_id: strategy.id, name: 'with_prereq') }
        it "will include permitted strategy_actions" do
          Models::Processing::StrategyEventPrerequisite.create!(
            guarded_strategy_event_id: guarded_event.id, prerequisite_strategy_event_id: event.id
          )
          expect(subject).to eq([guarded_event])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_strategy_events_without_prerequisites' do
        subject { test_repository.scope_strategy_events_without_prerequisites(entity: entity) }
        let(:guarded_event) { Models::Processing::StrategyEvent.create!(strategy_id: strategy.id, name: 'with_prereq') }
        it "will include actions that do not have prerequisites" do
          Models::Processing::StrategyEventPrerequisite.create!(
            guarded_strategy_event_id: guarded_event.id, prerequisite_strategy_event_id: event.id
          )
          event.save! unless event.persisted?
          expect(subject).to eq([event])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_statetegy_events_that_have_occurred' do
        subject { test_repository.scope_statetegy_events_that_have_occurred(entity: entity) }
        it "will include actions that do not have prerequisites" do
          Models::Processing::EntityEventRegister.create!(entity_id: entity.id, strategy_event_id: event.id)
          event.save! unless event.persisted?
          expect(subject).to eq([event])
        end
        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

      context '#scope_available_and_permitted_actions' do
        subject { test_repository.scope_available_and_permitted_actions(entity: entity, user: user) }
        let(:guarded_event) { Models::Processing::StrategyEvent.create!(strategy_id: strategy.id, name: 'with_prereq') }
        before do
          entity.strategy_state = originating_state
        end

        it "will include actions that do not have prerequisites" do
          event.save! unless event.persisted?
          action_with_completed_prerequisites = Models::Processing::StrategyEvent.create!(
            strategy_id: strategy.id, name: 'completed_prerequisites'
          ) do |current_action|
            current_action.requiring_strategy_event_prerequisites.build(prerequisite_strategy_event_id: event.id)
            current_action.entity_event_registers.build(entity_id: entity.id)
          end

          action_with_incomplete_prerequisites = Models::Processing::StrategyEvent.create!(
            strategy_id: strategy.id, name: 'without_prerequisites'
          ) do |current_action|
            current_action.requiring_strategy_event_prerequisites.build(
              prerequisite_strategy_event_id: action_with_completed_prerequisites.id
            )
          end

          event_with_no_prerequisites = Models::Processing::StrategyAction.create!(
            originating_strategy_state_id: originating_state.id, strategy_event_id: event.id
          )

          # Making sure that I have the expected counts
          expect(Models::Processing::StrategyEvent.count).to eq(3)
          expect(Models::Processing::EntityEventRegister.count).to eq(1)
          expect(Models::Processing::StrategyEventPrerequisite.count).to eq(2)

          expect(subject).to eq([event])
        end

        it "will be a chainable scope" do
          expect(subject).to be_a(ActiveRecord::Relation)
        end
      end

    end
  end
end
