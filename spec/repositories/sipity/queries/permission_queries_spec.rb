require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe PermissionQueries, type: :isolated_repository_module do

      context '#group_names_for_entity_and_acting_as' do
        Given(:acting_as) { 'etd_reviewer' }
        Given(:entity) { double('Entity') }
        When(:group_names) { test_repository.group_names_for_entity_and_acting_as(entity: entity, acting_as: acting_as) }
        Then { group_names == ['graduate_school'] }
      end

      context '#can_the_user_act_on_the_entity?' do
        let(:entity) { Models::Work.create! }
        let(:associated_user) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }
        let(:not_associated_user) { Sipity::Factories.create_user(email: 'not_associated@hotmail.com') }
        let(:acting_as) { 'arbitrary' }

        before do
          Models::Permission.create!(actor: associated_user, acting_as: acting_as, entity: entity)
          expect(test_repository).to receive(:scope_users_by_entity_and_acting_as).and_call_original
        end
        it 'will return true if there is a match on the user, acting_as, and entity' do
          expect(test_repository.can_the_user_act_on_the_entity?(user: associated_user, acting_as: acting_as, entity: entity)).
            to eq(true)
        end
        it 'will return false if there is NOT a match on the user, acting_as, and entity' do
          expect(test_repository.can_the_user_act_on_the_entity?(user: not_associated_user, acting_as: acting_as, entity: entity)).
            to eq(false)
        end
      end

      context '#deprecated_emails_for_associated_users' do
        let(:entity) { Models::Work.create! }
        let(:associated_user) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }
        let(:acting_as) { 'arbitrary' }

        before do
          Models::Permission.create!(actor: associated_user, acting_as: acting_as, entity: entity)
        end

        it 'will return emails from users directly associated with the entity' do
          # See tests for #scope_users_by_entity_and_acting_as; I'm just making sure the pluck works
          expect(test_repository).to receive(:scope_users_by_entity_and_acting_as).and_call_original
          results = test_repository.deprecated_emails_for_associated_users(acting_as: acting_as, entity: entity)
          expect(results.sort).to eq(['associated@hotmail.com'])
        end
      end

      context 'querying for augmented permission records' do
        let(:entity) { Models::Work.new(id: 1, work_type: 'etd', processing_state: 'new') }
        let(:user) { User.new(id: 2) }
        let(:group) { Models::Group.new(id: 3) }
        let(:direct_user_permission) do
          Models::Permission.new(
            actor_id: user.id, actor_type: user.class.base_class, acting_as: 'as_a_user',
            entity_id: entity.id, entity_type: entity.class.base_class
          )
        end
        let(:indirect_user_permission) do
          Models::Permission.new(
            actor_id: group.id, actor_type: group.class.base_class, acting_as: 'as_a_group',
            entity_id: entity.id, entity_type: entity.class.base_class
          )
        end
        before do
          Models::GroupMembership.create!(group_id: group.id, user_id: user.id)
        end

        context '#deprecated_available_event_triggers_for' do
          it 'will return an array of strings' do
            # TODO: This is a test coupled to the behavior of an existing state diagram.
            expect(test_repository).to receive(:user_can_act_as_the_following_on_entity).and_return(['creating_user'])
            actual = test_repository.deprecated_available_event_triggers_for(user: user, entity: entity)
            expect(actual).to eq(["update", "show", "delete", "submit_for_review"])
          end
        end

        context '#user_can_act_as_the_following_on_entity' do
          it 'will return an array of strings' do
            direct_user_permission.save!
            results = test_repository.user_can_act_as_the_following_on_entity(user: user, entity: entity)
            expect(results).to eq([direct_user_permission.acting_as])
          end
        end

        context '#scope_acting_as_by_entity_and_user' do
          context 'for direct user permission' do
            it 'will return an Active Record relationship' do
              direct_user_permission.save!
              results = test_repository.scope_acting_as_by_entity_and_user(user: user, entity: entity)
              expect(results.pluck(:acting_as).sort).to eq([direct_user_permission.acting_as].sort)
            end
          end

          context 'for both direct and indirect user permission' do
            it 'will return an Active Record relationship' do
              direct_user_permission.save!
              indirect_user_permission.save!
              results = test_repository.scope_acting_as_by_entity_and_user(user: user, entity: entity)
              expect(results.pluck(:acting_as).sort).to eq([direct_user_permission.acting_as, indirect_user_permission.acting_as].sort)
            end
          end
          context 'for indirect user permission via group' do
            it 'will return an Active Record relationship' do
              indirect_user_permission.save!
              results = test_repository.scope_acting_as_by_entity_and_user(user: user, entity: entity)
              expect(results.pluck(:acting_as).sort).to eq([indirect_user_permission.acting_as].sort)
            end
          end
        end
      end

      context '#scope_users_by_entity_and_acting_as' do
        let(:entity) { Models::Work.create! }
        let(:associated_user) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }
        let(:associated_by_group_user) { Sipity::Factories.create_user(email: 'group_associated@hotmail.com') }
        let(:not_associated_user) { Sipity::Factories.create_user(email: 'not_associated@hotmail.com') }
        let(:user_with_wrong_acting_as) { Sipity::Factories.create_user(email: 'wrong_acting_as@hotmail.com') }
        let(:associated_group) { Models::Group.create!(name: 'associated') }
        let(:acting_as) { 'arbitrary' }
        let(:wrong_acting_as) { 'wrong_acting_as' }

        before do
          Models::GroupMembership.create!(group: associated_group, user: associated_by_group_user)
          Models::Permission.create!(actor: user_with_wrong_acting_as, acting_as: wrong_acting_as, entity: entity)
          Models::Permission.create!(actor: associated_group, acting_as: acting_as, entity: entity)
          Models::Permission.create!(actor: associated_user, acting_as: acting_as, entity: entity)
        end

        it 'will return the users' do
          results = test_repository.scope_users_by_entity_and_acting_as(acting_as: acting_as, entity: entity)
          expect(results.sort).to eq([associated_user, associated_by_group_user].sort)
        end
      end

      context '#scope_entities_for_entity_type_and_user_acting_as' do
        let(:user) { User.new(id: 1234) }
        let(:group) { Models::Group.new(id: 5678) }
        let(:entity) { Models::Work.create! }
        let(:acting_as) { Models::Permission::CREATING_USER }
        subject { test_repository }

        it 'will return an empty result if we do not have a user' do
          expect(
            subject.scope_entities_for_entity_type_and_user_acting_as(
              user: nil, acting_as: ['creating_user'], entity_type: entity.class
            )
          ).to eq([])
        end

        it 'will return an empty result if there are no acting_as' do
          Models::Permission.create!(entity: entity, actor_id: user.id, actor_type: 'User', acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: [], entity_type: entity.class)).
            to_not include(entity)
        end
        it 'will return the entity for the creating user' do
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor_id: user.id, actor_type: 'User', acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to include(entity)
        end

        it 'will exclude the entity for a non creating user' do
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to_not include(entity)
        end

        it 'will return the entity for which the user is inferred by group' do
          Models::GroupMembership.create!(user_id: user.id, group: group)
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: group, acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to include(entity)
        end

        it 'will exclude the entity for which the user is not part of the group' do
          Models::Permission.create!(entity: entity, actor: group, acting_as: acting_as)
          expect(subject.scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: acting_as, entity_type: entity.class)).
            to_not include(entity)
        end
      end
    end
  end
end
