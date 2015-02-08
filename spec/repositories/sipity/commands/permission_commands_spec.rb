require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe PermissionCommands, type: :isolated_repository_module do
      subject { test_repository }
      before do
        # TODO: Remove this once the deprecation for granting permission is done
        allow(Services::GrantProcessingPermission).to receive(:call)
      end

      context '#grant_creating_user_permission_for!' do
        # REVIEW: The entity, user, and group are all being created. Is it time
        #   to consider using fixtures?
        let(:entity) { Models::Work.new(id: 1) }
        let(:user) { Factories.create_user }
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
