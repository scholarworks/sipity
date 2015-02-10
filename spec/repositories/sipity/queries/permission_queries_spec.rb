require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe PermissionQueries, type: :isolated_repository_module do
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
      end

      context '#deprecated_scope_entities_for_entity_type_and_user_acting_as' do
        let(:user) { User.new(id: 1234) }
        let(:group) { Models::Group.new(id: 5678) }
        let(:entity) { Models::Work.create! }
        let(:acting_as) { Models::Permission::CREATING_USER }
        subject { test_repository }

        it 'will return an empty result if we do not have a user' do
          expect(
            subject.deprecated_scope_entities_for_entity_type_and_user_acting_as(
              user: nil, acting_as: ['creating_user'], entity_type: entity.class
            )
          ).to eq([])
        end

        it 'will return an empty result if there are no acting_as' do
          Models::Permission.create!(entity: entity, actor_id: user.id, actor_type: 'User', acting_as: acting_as)
          expect(
            subject.deprecated_scope_entities_for_entity_type_and_user_acting_as(user: user, acting_as: [], entity_type: entity.class)
          ).to_not include(entity)
        end
        it 'will return the entity for the creating user' do
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor_id: user.id, actor_type: 'User', acting_as: acting_as)
          expect(
            subject.deprecated_scope_entities_for_entity_type_and_user_acting_as(
              user: user, acting_as: acting_as, entity_type: entity.class
            )
          ).to include(entity)
        end

        it 'will exclude the entity for a non creating user' do
          expect(
            subject.deprecated_scope_entities_for_entity_type_and_user_acting_as(
              user: user, acting_as: acting_as, entity_type: entity.class
            )
          ).to_not include(entity)
        end

        it 'will return the entity for which the user is inferred by group' do
          Models::GroupMembership.create!(user_id: user.id, group: group)
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: group, acting_as: acting_as)
          expect(
            subject.deprecated_scope_entities_for_entity_type_and_user_acting_as(
              user: user, acting_as: acting_as, entity_type: entity.class
            )
          ).to include(entity)
        end

        it 'will exclude the entity for which the user is not part of the group' do
          Models::Permission.create!(entity: entity, actor: group, acting_as: acting_as)
          expect(
            subject.deprecated_scope_entities_for_entity_type_and_user_acting_as(
              user: user, acting_as: acting_as, entity_type: entity.class
            )
          ).to_not include(entity)
        end
      end
    end
  end
end
