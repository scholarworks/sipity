require 'spec_helper'

module Sipity
  module Queries
    # Queries
    RSpec.describe PermissionQueries, type: :repository_methods do
      context '#scope_permission_resolver' do
        let(:user) { User.new(id: 1234) }
        let(:group) { Models::Group.new(id: 5678) }
        let(:entity) { Models::Header.create! }
        let(:role) { Models::Permission::CREATING_USER }
        subject { test_repository }

        it 'will return an empty result if there are no roles' do
          Models::Permission.create!(entity: entity, actor: user, role: role)
          expect(subject.scope_permission_resolver(user: user, roles: [], entity_type: entity.class.base_class)).to_not include(entity)
        end
        it 'will return the entity for the creating user' do
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: user, role: role)
          expect(subject.scope_permission_resolver(user: user, roles: role, entity_type: entity.class.base_class)).to include(entity)
        end

        it 'will exclude the entity for a non creating user' do
          expect(subject.scope_permission_resolver(user: user, roles: role, entity_type: entity.class.base_class)).to_not include(entity)
        end

        it 'will return the entity for which the user is inferred by group' do
          Models::GroupMembership.create!(user: user, group: group)
          # TODO: Tease apart this service method; Its a command that I want to
          #   leverage.
          # TODO: I have knowledge of the applicable ROLE, this should be passed to the
          #   resolver.
          Models::Permission.create!(entity: entity, actor: group, role: role)
          expect(subject.scope_permission_resolver(user: user, roles: role, entity_type: entity.class.base_class)).to include(entity)
        end

        it 'will exclude the entity for which the user is not part of the group' do
          Models::Permission.create!(entity: entity, actor: group, role: role)
          expect(subject.scope_permission_resolver(user: user, roles: role, entity_type: entity.class.base_class)).to_not include(entity)
        end
      end
    end
  end
end
