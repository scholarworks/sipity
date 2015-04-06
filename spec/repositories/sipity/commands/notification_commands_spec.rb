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
          allow(Queries::ProcessingQueries).to receive(:user_emails_for_entity_and_roles).and_return(emails)
          allow(Services::Notifier).to receive(:deliver).with(notification: notification, to: emails, entity: entity, bcc: [], cc: [])
          test_repository.send_notification_for_entity_trigger(notification: notification, entity: entity, acting_as: acting_as)
        end
      end
    end
  end
end
