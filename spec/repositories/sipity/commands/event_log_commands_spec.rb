require 'spec_helper'
require 'sipity/commands/event_log_commands'

module Sipity
  module Commands
    RSpec.describe EventLogCommands, type: :isolated_repository_module do
      let(:user) { Models::IdentifiableAgent.new_from_netid(netid: 'hworld') }
      let(:event_name) { 'event_name' }

      context '#log_event!' do
        context 'with an entity that can be polymorphic' do
          let(:entity) { Models::Work.new(id: 1) }
          it 'will increment the log count' do
            test_repository.log_event!(requested_by: user, entity: entity, event_name: event_name)
            expect(Models::EventLog.count).to eq(1)
          end
        end

        context 'with an entity that can be converted to an identifier_id' do
          let(:identifiable_agent) { double(identifier_id: '123') }
          let(:entity) { double('Hello', to_identifiable_agent: identifiable_agent) }
          it 'will increment the log count' do
            test_repository.log_event!(requested_by: user, entity: entity, event_name: event_name)
            expect(Models::EventLog.count).to eq(1)
          end
        end

        context 'with an entity that cannot be converted' do
          let(:entity) { double('Hello') }
          it 'will increment the log count' do
            expect do
              test_repository.log_event!(requested_by: user, entity: entity, event_name: event_name)
            end.to raise_error(PowerConverter::ConversionError)
          end
        end
      end
    end
  end
end
