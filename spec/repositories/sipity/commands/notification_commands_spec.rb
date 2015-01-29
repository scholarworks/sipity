require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe NotificationCommands, type: :isolated_repository_module do
      context '#send_notification_for_entity_trigger' do
        let(:notification) { double }
        let(:entity) { double }
        let(:acting_as) { double }
        let(:emails) { ['test@hello.com'] }

        it 'is a placeholder' do
          allow(Queries::PermissionQueries).to receive(:emails_for_associated_users).and_return(emails)
          allow(Services::Notifier).to receive(:deliver).with(notification: notification, to: emails, entity: entity)
          test_repository.send_notification_for_entity_trigger(notification: notification, entity: entity, acting_as: acting_as)
        end
      end
    end
  end
end
