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
      context '#confirmation_of_entity_submitted_for_review' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_entity_submitted_for_review(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#request_revision_from_creator' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.request_revision_from_creator(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#entity_ready_for_review' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.entity_ready_for_review(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#entity_ready_for_cataloging' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.entity_ready_for_cataloging(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#request_revision_from_creator' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.request_revision_from_creator(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#entity_ready_for_review' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.entity_ready_for_review(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#entity_ready_for_cataloging' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.entity_ready_for_cataloging(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#confirmation_of_entity_ingested' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_entity_ingested(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#advisor_requests_change' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.advisor_requests_change(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
      context '#grad_school_requests_change' do
        let(:entity) { Models::Work.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.grad_school_requests_change(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
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
