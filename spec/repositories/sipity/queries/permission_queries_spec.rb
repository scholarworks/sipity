require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe PermissionQueries, type: :repository_methods do
      context '#emails_for_associated_users' do
        let(:entity) { Models::Sip.create! }
        let(:associated_user) { Sipity::Factories.create_user(email: 'associated@hotmail.com') }
        let(:associated_by_group_user) { Sipity::Factories.create_user(email: 'group_associated@hotmail.com') }
        let(:not_associated_user) { Sipity::Factories.create_user(email: 'not_associated@hotmail.com') }
        let(:user_with_wrong_role) { Sipity::Factories.create_user(email: 'wrong_role@hotmail.com') }
        let(:associated_group) { Models::Group.create!(name: 'associated') }
        let(:role) { 'arbitrary' }
        let(:wrong_role) { 'wrong_role' }

        before do
          # REVIEW: Should I be using Repository services?
          Models::GroupMembership.create!(group: associated_group, user: associated_by_group_user)

          Models::Permission.create!(actor: user_with_wrong_role, role: wrong_role, entity: entity)
          Models::Permission.create!(actor: associated_group, role: role, entity: entity)
          Models::Permission.create!(actor: associated_user, role: role, entity: entity)
        end

        it 'will return emails from users directly associated with the entity' do
          results = test_repository.emails_for_associated_users(roles: role, entity: entity)
          expect(results.sort).to eq(['associated@hotmail.com', 'group_associated@hotmail.com'])
        end
      end

      context '#scope_entities_for_user_and_roles_and_entity_type' do
        let(:user) { User.new(id: 1234) }
        let(:group) { Models::Group.new(id: 5678) }
        let(:entity) { Models::Sip.create! }
        let(:role) { Models::Permission::CREATING_USER }
        subject { test_repository }

        it 'will return an empty result if there are no roles' do
          Models::Permission.create!(entity: entity, actor: user, role: role)
          expect(subject.scope_entities_for_user_and_roles_and_entity_type(user: user, roles: [], entity_type: entity.class)).
            to_not include(entity)
        end
        it 'will return the entity for the creating user' do
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: user, role: role)
          expect(subject.scope_entities_for_user_and_roles_and_entity_type(user: user, roles: role, entity_type: entity.class)).
            to include(entity)
        end

        it 'will exclude the entity for a non creating user' do
          expect(subject.scope_entities_for_user_and_roles_and_entity_type(user: user, roles: role, entity_type: entity.class)).
            to_not include(entity)
        end

        it 'will return the entity for which the user is inferred by group' do
          Models::GroupMembership.create!(user: user, group: group)
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: group, role: role)
          expect(subject.scope_entities_for_user_and_roles_and_entity_type(user: user, roles: role, entity_type: entity.class)).
            to include(entity)
        end

        it 'will exclude the entity for which the user is not part of the group' do
          Models::Permission.create!(entity: entity, actor: group, role: role)
          expect(subject.scope_entities_for_user_and_roles_and_entity_type(user: user, roles: role, entity_type: entity.class)).
            to_not include(entity)
        end
      end
    end
  end
end
