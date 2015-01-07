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
        let(:entity) { Models::Sip.new }
        let(:to) { 'test@example.com' }
        it 'should send an email' do
          described_class.confirmation_of_entity_submitted_for_review(entity: entity, to: to).deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
    end
  end
end
