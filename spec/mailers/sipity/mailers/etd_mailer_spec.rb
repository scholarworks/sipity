require 'spec_helper'
require 'sipity/mailers/etd_mailer'
module Sipity
  module Mailers
    describe EtdMailer do
      around do |example|
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
        Cogitate::Client.with_custom_configuration(
          client_request_handler: ->(*) { Rails.root.join('spec/fixtures/cogitate/group_with_agents.response.json').read }
        ) { example.run }
        ActionMailer::Base.deliveries.clear
      end

      before do
        allow(work).to receive(:persisted?).and_return(true)
      end

      let(:work) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation', title: 'a title') }
      let(:processing_entity) { work.build_processing_entity(strategy_id: '1', strategy_state_id: '1', proxy_for: work) }
      let(:user) { User.new(name: 'User') }
      let(:actor) { Models::Processing::Actor.new(proxy_for: user) }
      let(:to) { 'test@example.com' }
      let(:identifier_matching_json_config) { 'bmV0aWQJc2hpbGwy' }
      let(:comment) do
        Models::Processing::Comment.new(actor: actor, entity: processing_entity, identifier_id: identifier_matching_json_config)
      end
      let(:action) do
        Models::Processing::EntityActionRegister.new(
          entity: processing_entity, on_behalf_of_actor: actor, created_at: Time.zone.now,
          on_behalf_of_identifier_id: identifier_matching_json_config
        )
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
