require 'spec_helper'

module Sipity
  module Commands
    RSpec.describe EventLogCommands, type: :isolated_repository_module do
      Given(:user) { User.new(id: 1, username: 'tim') }
      Given(:entity) { Models::Work.new(id: 1) }
      Given(:event_name) { 'event_name' }

      context '#log_event!' do
        When(:result) { test_repository.log_event!(requested_by: user, entity: entity, event_name: event_name) }
        Then { result.persisted? }
        Then { Models::EventLog.count == 1 }
      end
    end
  end
end
