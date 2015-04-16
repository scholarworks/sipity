require 'spec_helper'

module Sipity
  module Services
    RSpec.describe DeliverFormSubmissionNotificationsService do
      let(:notification_context) { double(action: action, entity: entity) }
      let(:entity) { double('Entity') }
      let(:action) { double(emails: [email]) }
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

      subject { described_class.new(notification_context, repository: repository, notifier: notifier) }

      its(:default_repository) { should respond_to :user_emails_for_entity_and_roles }
      its(:default_notifier) { should respond_to :call }

      before do
        allow(repository).to receive(:user_emails_for_entity_and_roles).with(entity: entity, roles: role_for_to).and_return(to_emails)
        allow(repository).to receive(:user_emails_for_entity_and_roles).with(entity: entity, roles: role_for_cc).and_return(cc_emails)
      end

      context '#call' do
        it 'will deliver each of the action emails to the associated recipients based on role' do
          expect(notifier).to receive(:call).
            with(notification: email.method_name, entity: entity, to: to_emails, cc: cc_emails, bcc: bcc_emails)
          subject.call
        end
      end
    end
  end
end
