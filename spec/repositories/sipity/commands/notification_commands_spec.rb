require "rails_helper"
require 'sipity/commands/notification_commands'

module Sipity
  module Commands
    RSpec.describe NotificationCommands, type: :isolated_repository_module do
      context '#deliver_notification_for' do
        let(:parameters) { { scope: double, the_thing: double, requested_by: double, on_behalf_of: double } }
        it 'will delegate to the DeliverFormSubmissionNotificationsService' do
          expect(Services::DeliverFormSubmissionNotificationsService).to receive(:call)
          test_repository.deliver_notification_for(parameters)
        end
      end
    end
  end
end
