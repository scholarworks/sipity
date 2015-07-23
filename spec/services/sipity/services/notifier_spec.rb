require 'spec_helper'

module Sipity
  module Services
    describe Notifier do
      context '.deliver' do
        let(:missing_notification) { 'never_would_this_be_a_notification' }
        let(:emails) { ['hello@world.com'] }
        let(:entity) { double('Entity') }
        let(:mail_object) { double('Mail', deliver_now: true) }
        let(:existing_notification) { 'confirmation_of_submit_for_review' }

        it 'will raise an exception if a corresponding email notifier does not exist' do
          expect { described_class.deliver(notification: missing_notification, to: emails) }.
            to raise_error(Exceptions::NotificationNotFoundError)
        end

        it 'will deliver an email notifier if the named notification exists' do
          expect(Mailers::EmailNotifier).to receive(existing_notification).
            with(entity: entity, to: emails, cc: [], bcc: []).and_return(mail_object)

          described_class.deliver(entity: entity, notification: existing_notification, to: emails)

          expect(mail_object).to have_received(:deliver_now)
        end

        it 'will not attempt deliver email notifier if sender not exists' do
          described_class.deliver(entity: entity, notification: existing_notification, to: [])
          expect(mail_object).to_not have_received(:deliver_now)
        end
      end
    end
  end
end
