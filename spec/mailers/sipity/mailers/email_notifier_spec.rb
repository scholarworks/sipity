require 'spec_helper'
module Sipity
  module Mailers
    describe EmailNotifier do
      before do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
      end
      after do
        ActionMailer::Base.deliveries.clear
      end

      let(:work) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation') }
      let(:processing_entity) { work.build_processing_entity(strategy_id: '1', strategy_state_id: '1', proxy_for: work) }
      let(:user) { User.new(name: 'User') }
      let(:actor) { Models::Processing::Actor.new(proxy_for: user) }
      let(:to) { 'test@example.com' }

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_WORK.each do |work_notification_method_name|
        context "##{work_notification_method_name}" do
          it 'should send an email' do
            processing_entity # making sure its declared
            described_class.send(work_notification_method_name, entity: work, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_PROCESSING_COMMENTS.each do |email_method|
        context "##{email_method}" do
          let(:processing_comment) { Models::Processing::Comment.new(actor: actor, entity: processing_entity) }
          it 'should send an email' do
            described_class.send(email_method, entity: processing_comment, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_REGISTERED_ACTION.each do |email_method|
        context "##{email_method}" do
          # YOWZA! This is a lot of collaborators!
          let(:registered_action) { Models::Processing::EntityActionRegister.new(entity: processing_entity, on_behalf_of_actor: actor) }
          it 'should send an email' do
            described_class.send(email_method, entity: registered_action, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end
    end
  end
end
