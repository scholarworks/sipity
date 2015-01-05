require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe NotificationCommands, type: :repository_methods do
      context '#send_notification_for_entity_trigger' do
        let(:notification) { double }
        let(:entity) { double }
        let(:to_roles) { double }
        let(:emails) { ['test@hello.com'] }

        it 'is a placeholder' do
          allow(Queries::PermissionQueries).to receive(:emails_for_associated_users).and_return(emails)
          allow(Services::Notifier).to receive(:deliver).with(notification: notification, email: emails, entity: entity)
          test_repository.send_notification_for_entity_trigger(notification: notification, entity: entity, to_roles: to_roles)
        end
      end
    end
  end
end
