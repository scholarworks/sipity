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

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_WORK.each do |work_notification_method_name|
        context "##{work_notification_method_name}" do
          let(:entity) { Models::Work.new(id: '123') }
          let(:to) { 'test@example.com' }
          it 'should send an email' do
            entity.build_processing_entity(strategy_id: '1', strategy_state_id: '1')
            described_class.send(work_notification_method_name, entity: entity, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_PROCESSING_COMMENTS.each do |email_method|
        context "##{email_method}" do
          let(:entity) { double('Hello') }
          let(:decorated) do
            double(email_subject: 'A subject', name_of_commentor: 'A name', comment: "A comment", document_type: "A document_type")
          end
          let(:decorator) { double(new: decorated) }
          let(:to) { 'test@example.com' }
          it 'should send an email' do
            described_class.send(email_method, entity: entity, to: to, decorator: decorator).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
          it 'should have a valid default decorator' do
            expect(Decorators::Emails::ProcessingCommentDecorator).to receive(:new).and_return(decorated)
            described_class.send(email_method, entity: entity, to: to).deliver_now
          end
        end
      end

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_REGISTERED_ACTION.each do |email_method|
        context "##{email_method}" do
          # YOWZA! This is a lot of collaborators!
          let(:work) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation') }
          let(:processing_entity) { work.build_processing_entity(strategy_id: '1', strategy_state_id: '1', proxy_for: work) }
          let(:user) { User.new(name: 'User') }
          let(:actor) { Models::Processing::Actor.new(proxy_for: user) }
          let(:entity) { Models::Processing::EntityActionRegister.new(entity: processing_entity, on_behalf_of_actor: actor) }
          let(:to) { 'test@example.com' }
          it 'should send an email' do
            described_class.send(email_method, entity: entity, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      context '#confirmation_of_grad_school_signoff' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_grad_school_signoff(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
    end
  end
end
