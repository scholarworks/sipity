require 'spec_helper'
require 'sipity/mailers/etd_mailer'
module Sipity
  module Mailers
    describe EtdMailer do
      before do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
        allow(work).to receive(:persisted?).and_return(true)
      end
      after do
        ActionMailer::Base.deliveries.clear
      end

      let(:work) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation', title: 'a title') }
      let(:processing_entity) { work.build_processing_entity(strategy_id: '1', strategy_state_id: '1', proxy_for: work) }
      let(:user) { User.new(name: 'User') }
      let(:actor) { Models::Processing::Actor.new(proxy_for: user) }
      let(:to) { 'test@example.com' }

      described_class::NOTIFCATION_METHOD_NAMES_FOR_WORK.each do |work_notification_method_name|
        context "##{work_notification_method_name}" do
          it 'should send an email' do
            processing_entity # making sure its declared
            described_class.send(work_notification_method_name, entity: work, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      described_class::NOTIFCATION_METHOD_NAMES_FOR_PROCESSING_COMMENTS.each do |email_method|
        context "##{email_method}" do
          let(:processing_comment) { Models::Processing::Comment.new(actor: actor, entity: processing_entity) }
          it 'should send an email' do
            described_class.send(email_method, entity: processing_comment, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      described_class::NOTIFCATION_METHOD_NAMES_FOR_REGISTERED_ACTION.each do |email_method|
        context "##{email_method}" do
          # YOWZA! This is a lot of collaborators!
          let(:registered_action) do
            Models::Processing::EntityActionRegister.new(entity: processing_entity, on_behalf_of_actor: actor, created_at: Time.zone.now)
          end
          it 'should send an email' do
            described_class.send(email_method, entity: registered_action, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end
    end
  end
end
