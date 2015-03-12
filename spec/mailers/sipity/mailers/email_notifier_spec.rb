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
      context '#confirmation_of_submit_for_review' do
        let(:entity) { Models::Work.new(id: '123') }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_submit_for_review(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#confirmation_of_entity_created' do
        let(:entity) { double('Hello') }
        let(:decorated) do
          double(title: 'A title', review_link: "link to work show", document_type: "A document_type")
        end
        let(:decorator) { double(new: decorated) }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_entity_created(entity: entity, to: to, decorator: decorator).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      context '#submit_for_review' do
        let(:entity) { Models::Work.new(id: '123') }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          entity.build_processing_entity(strategy_id: '1', strategy_state_id: '1')
          described_class.submit_for_review(entity: entity, to: to).deliver_now
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      [
        'advisor_signoff_is_complete',
        'confirmation_of_advisor_signoff_is_complete'
      ].each_with_index do |email_method, index|
        context "##{email_method} (Scenario #{index})" do
          let(:entity) { Models::Work.new(id: '123') }
          let(:to) { 'test@example.com' }
          it 'should send an email' do
            entity.build_processing_entity(strategy_id: '1', strategy_state_id: '1')
            described_class.send(email_method, entity: entity, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      context '#confirmation_of_advisor_signoff' do
        # YOWZA! This is a lot of collaborators!
        let(:work) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation') }
        let(:processing_entity) { work.build_processing_entity(strategy_id: '1', strategy_state_id: '1', proxy_for: work) }
        let(:user) { User.new(name: 'User') }
        let(:actor) { Models::Processing::Actor.new(proxy_for: user) }
        let(:entity) { Models::Processing::EntityActionRegister.new(entity: processing_entity, on_behalf_of_actor: actor) }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_advisor_signoff(entity: entity, to: to).deliver_now
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      [
        'grad_school_requests_change',
        'advisor_requests_change'
      ].each_with_index do |email_method, index|
        context "##{email_method} (Scenario #{index})" do
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
