require 'spec_helper'
require 'sipity/commands/permission_commands'

module Sipity
  module Commands
    RSpec.describe PermissionCommands, type: :isolated_repository_module do
      subject { test_repository }
      context '#grant_creating_user_permission_for!' do
        let(:entity) { Models::Work.new(id: 1) }
        let(:user) { Models::IdentifiableAgent.new_from_netid(netid: 'hworld') }

        it 'will use the :user parameter to write a permission' do
          allow(Services::ProcessingPermissionHandler).to receive(:grant)
          subject.grant_creating_user_permission_for!(entity: entity, user: user)
        end
      end
    end
  end
end
