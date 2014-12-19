require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe PermissionCommands, type: :repository_methods do
      subject { test_repository }

      context '#grant_groups_permission_to_entity_for_role!' do
        let(:entity) { Models::Header.new(id: 1) }
        context 'with a role' do
          context 'that has one (or more) groups associated by header type' do
            it 'will assign that group permission to the given header' do
              expect { subject.grant_groups_permission_to_entity_for_role!(entity: entity, roles: 'etd_reviewer') }.
                to change { Models::Permission.count }.by(1)
            end
          end
          context 'that has NO groups associated' do
            it 'will raise an exception' do
              expect { subject.grant_groups_permission_to_entity_for_role!(entity: entity, roles: '__missing__') }.
                to raise_error(KeyError)
            end
          end
        end
      end

      context '#grant_creating_user_permission_for!' do
        let(:entity) { Models::Sip.new(id: 1) }
        let(:user) { User.new(id: 2) }
        let(:group) { Models::Group.new(id: 3) }

        it 'will use the :user parameter to write a permission' do
          expect { subject.grant_creating_user_permission_for!(entity: entity, user: user) }.
            to change { Models::Permission.count }.by(1)
        end

        it 'will use the :group parameter to write a permission' do
          expect { subject.grant_creating_user_permission_for!(entity: entity, group: group) }.
            to change { Models::Permission.count }.by(1)
        end

        it 'will use the :actor parameter to write a permission' do
          expect { subject.grant_creating_user_permission_for!(entity: entity, actor: group) }.
            to change { Models::Permission.count }.by(1)
        end

        it 'will use the :actor (or :user or :group) to write multiple permissions' do
          expect { subject.grant_creating_user_permission_for!(entity: entity, actor: [group, user]) }.
            to change { Models::Permission.count }.by(2)
        end
      end
    end
  end
end
