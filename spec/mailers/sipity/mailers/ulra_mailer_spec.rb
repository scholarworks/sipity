require "rails_helper"
require 'sipity/mailers/etd_mailer'
module Sipity
  module Mailers
    describe UlraMailer do
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

      described_class.emails.each do |email|
        context "##{email.method_name}" do
          it 'should send an email' do
            processing_entity # making sure its declared
            described_class.send(email.method_name, entity: work, to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end
    end
  end
end
