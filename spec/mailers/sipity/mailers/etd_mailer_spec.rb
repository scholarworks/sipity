require "rails_helper"
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
      let(:comment) { Models::Processing::Comment.new(actor: actor, entity: processing_entity) }
      let(:action) do
        Models::Processing::EntityActionRegister.new(entity: processing_entity, on_behalf_of_actor: actor, created_at: Time.zone.now)
      end

      described_class.emails.each do |email|
        context "##{email.method_name}" do
          it 'should send an email' do
            processing_entity
            described_class.send(email.method_name, entity: send(email.as), to: to).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end
    end
  end
end
