require 'rails_helper'
require 'sipity/services/deliver_form_submission_notifications_service'

module Sipity
  module Services
    RSpec.describe DeliverFormSubmissionNotificationsService do
      let(:notification_context) { Parameters::NotificationContextParameter.new(scope: scope, the_thing: the_thing) }
      let(:the_thing) { double('Entity') }
      let(:scope) { Models::Processing::StrategyAction.new }
      let(:repository) { QueryRepositoryInterface.new }
      let(:notifier) { Services::Notifier }
      let(:role_for_to) { Models::Role.new }
      let(:to_emails) { ['hello@world.com'] }
      let(:cc_emails) { ['goodbye@cruelworld.com'] }
      let(:bcc_emails) { [] }
      let(:role_for_cc) { Models::Role.new }
      let(:email) do
        Models::Notification::Email.new(method_name: 'notification_method_name') do |email|
          email.recipients.build(role: role_for_to, recipient_strategy: 'to')
          email.recipients.build(role: role_for_cc, recipient_strategy: 'cc')
        end
      end

      subject { described_class.new(notification_context: notification_context, repository: repository, notifier: notifier) }

      its(:default_repository) { is_expected.to respond_to :user_emails_for_entity_and_roles }
      its(:default_notifier) { is_expected.to respond_to :call }

      before do
        allow(repository).to receive(:email_notifications_for).and_return([email])
        allow(repository).to receive(:user_emails_for_entity_and_roles).with(entity: the_thing, roles: role_for_to).and_return(to_emails)
        allow(repository).to receive(:user_emails_for_entity_and_roles).with(entity: the_thing, roles: role_for_cc).and_return(cc_emails)
      end

      it 'will expose .call as a convenience method' do
        expect(described_class).to receive_message_chain(:new, :call)
        described_class.call(notification_context: notification_context)
      end

      context '#call' do
        it 'will deliver each of the scope emails to the associated recipients based on role' do
          expect(notifier).to receive(:call).
            with(notification: email.method_name, entity: the_thing, to: to_emails, cc: cc_emails, bcc: bcc_emails)
          subject.call
        end
      end
    end
  end
end
