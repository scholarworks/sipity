require "rails_helper"
require 'sipity/commands/permission_commands'

module Sipity
  module Commands
    RSpec.describe PermissionCommands, type: :isolated_repository_module do
      subject { test_repository }
      before do
      end

      context '#grant_creating_user_permission_for!' do
        # REVIEW: The entity, user, and group are all being created. Is it time
        #   to consider using fixtures?
        let(:entity) { Models::Work.new(id: 1) }
        let(:user) { User.new(id: 2) }
        let(:group) { Models::Group.new(id: 3) }

        it 'will use the :user parameter to write a permission' do
          # TODO: Remove this once the deprecation for granting permission is done
          allow(Services::GrantProcessingPermission).to receive(:call)
          subject.grant_creating_user_permission_for!(entity: entity, user: user)
        end
      end
    end
  end
end
