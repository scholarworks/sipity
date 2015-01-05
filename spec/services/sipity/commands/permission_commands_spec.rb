require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe PermissionCommands, type: :repository_methods do
      subject { test_repository }

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
