require "rails_helper"
require 'sipity/commands/event_log_commands'

module Sipity
  module Commands
    RSpec.describe EventLogCommands, type: :isolated_repository_module do
      let(:user) { User.new(id: 1, username: 'tim') }
      let(:entity) { Models::Work.new(id: 1) }
      let(:event_name) { 'event_name' }

      context '#log_event!' do
        subject { test_repository.log_event!(requested_by: user, entity: entity, event_name: event_name) }
        it { is_expected.to be_persisted }
        it 'should change the EventLog count' do
          expect { subject }.to change(Models::EventLog, :count).by(1)
        end
      end
    end
  end
end
