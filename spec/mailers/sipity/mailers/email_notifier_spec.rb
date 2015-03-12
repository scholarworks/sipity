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
      context '#request_revision_from_creator' do
        let(:entity) { Models::Work.new(id: '123') }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.request_revision_from_creator(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#request_revision_from_creator' do
        let(:entity) { Models::Work.new(id: '123') }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.request_revision_from_creator(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      context '#submit_for_review' do
        let(:entity) { double('Hello') }
        let(:decorated) do
          double(creator_names: 'A name', creator_usernames: 'netid',
                 review_link: "link to work show", document_type: "A document_type", email_subject: "This is a subject")
        end
        let(:decorator) { double(new: decorated) }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.submit_for_review(entity: entity, to: to, decorator: decorator).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      [
        'advisor_signoff_is_complete',
        'confirmation_of_advisor_signoff_is_complete'
      ].each_with_index do |email_method, index|
        context "##{email_method} (Scenario #{index})" do
          let(:entity) { Models::Work.create!(id: '123') }
          let(:to) { 'test@example.com' }
          it 'should send an email' do
            entity.create_processing_entity!(strategy_id: '1', strategy_state_id: '1')
            described_class.send(email_method, entity: entity, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      context '#confirmation_of_entity_ingested' do
        let(:repository) { QueryRepositoryInterface.new }
        let(:entity) { double('Hello') }
        let(:to) { 'test@example.com' }
        let(:decorated) do
          double(creator_names: 'A name', creator_usernames: 'netid', created_at: "A Date", document_type: "A document_type",
                 title: 'A title', netid: 'A net id', graduate_programs: 'Program Name', curate_link: 'link')
        end
        let(:decorator) { double(new: decorated) }

        it 'should send an email' do
          described_class.confirmation_of_entity_ingested(entity: entity, to: to, decorator: decorator).deliver_now

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
      context '#advisor_signoff_but_still_more_to_go' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.advisor_signoff_but_still_more_to_go(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
    end
  end
end
