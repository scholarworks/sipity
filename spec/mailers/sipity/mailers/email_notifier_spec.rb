require 'spec_helper'
require 'sipity/mailers/email_notifier'
module Sipity
  module Mailers
    describe EmailNotifier do
      # A hack to ensure I'm not persisting this thing
      before { allow(work).to receive(:persisted?).and_return(true) }
      around do |scenario|
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
        Cogitate::Client.with_custom_configuration(
          client_request_handler: ->(*) { Rails.root.join('spec/fixtures/cogitate/group_with_agents.response.json').read }
        ) do
          scenario.run
        end
        ActionMailer::Base.deliveries.clear
      end

      let(:work) { Models::Work.new(id: '123', work_type: 'doctoral_dissertation', title: 'a title') }
      let(:repository) { QueryRepositoryInterface.new }
      let(:processing_entity) { work.build_processing_entity(strategy_id: '1', strategy_state_id: '1', proxy_for: work) }
      let(:identifiable_agent) { Models::IdentifiableAgent.new_from_netid(netid: 'hworld') }
      let(:to) { 'test@example.com' }

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_WORK.each do |work_notification_method_name|
        context "##{work_notification_method_name}" do
          it 'should send an email' do
            processing_entity # making sure its declared
            described_class.send(work_notification_method_name, entity: work, to: to, repository: repository).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_PROCESSING_COMMENTS.each do |email_method|
        context "##{email_method}" do
          let(:processing_comment) do
            Models::Processing::Comment.new(identifier_id: identifiable_agent.identifier_id, entity: processing_entity)
          end
          it 'should send an email' do
            described_class.send(email_method, entity: processing_comment, to: to, repository: repository).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      EmailNotifier::NOTIFCATION_METHOD_NAMES_FOR_REGISTERED_ACTION.each do |email_method|
        context "##{email_method}" do
          # YOWZA! This is a lot of collaborators!
          let(:registered_action) do
            Models::Processing::EntityActionRegister.new(
              entity: processing_entity, on_behalf_of_identifier_id: identifiable_agent.identifier_id, created_at: Time.zone.now
            )
          end
          it 'should send an email' do
            described_class.send(email_method, entity: registered_action, to: to, repository: repository).deliver_now
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end
    end
  end
end
