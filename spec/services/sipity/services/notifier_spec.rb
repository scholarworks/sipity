require 'spec_helper'
require 'sipity/services/notifier'

module Sipity
  module Services
    describe Notifier do
      context '.default_email_service_finder' do
        subject { described_class.send(:default_email_service_finder) }
        its(:parameters) { is_expected.to eq([[:keyreq, :entity], [:keyreq, :notification]]) }
      end
      context '.deliver' do
        let(:missing_notification) { 'never_would_this_be_a_notification' }
        let(:emails) { ['hello@world.com'] }
        let(:entity) { double('Entity') }
        let(:mail_object) { double('Mail', deliver_now: true) }
        let(:email_service_finder) { ->(*) { mailer } }
        let(:mailer) { Mailers::EtdMailer }
        let(:existing_notification) { 'confirmation_of_submit_for_review' }

        it 'will deliver an email notifier if the named notification exists' do
          expect(mailer).to receive(existing_notification).
            with(entity: entity, to: emails, cc: [], bcc: []).and_return(mail_object)

          described_class.deliver(
            email_service_finder: email_service_finder, entity: entity, notification: existing_notification, to: emails
          )

          expect(mail_object).to have_received(:deliver_now)
        end

        it 'will not attempt deliver email notifier if sender not exists' do
          described_class.deliver(email_service_finder: email_service_finder, entity: entity, notification: existing_notification, to: [])
          expect(mail_object).to_not have_received(:deliver_now)
        end
      end
    end
  end
end
