require 'spec_helper'

module Sipity
  module Repo
    RSpec.describe EventLogMethods, type: :repository_methods do
      context '#sequence_of_events_for' do
        Given(:user) { User.new(id: 1) }
        When(:results) { test_repository.sequence_of_events_for(user: user) }
        Then { results.is_a?(ActiveRecord::Relation) }
      end

      context '#log_event!' do
        Given(:user) { User.new(id: 1) }
        Given(:entity) { Models::Header.new(id: 1) }
        Given(:event_name) { 'event_name' }
        When(:result) { test_repository.log_event!(user: user, entity: entity, event_name: event_name) }
        Then { result.persisted? }
        Then { Models::EventLog.count == 1 }
      end
    end
  end
end
