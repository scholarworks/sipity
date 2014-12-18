require 'spec_helper'

module Sipity
  module RepositoryMethods
    RSpec.describe EventLogMethods, type: :repository_methods do
      Given(:user) { User.new(id: 1) }
      Given(:entity) { Models::Header.new(id: 1) }
      Given(:event_name) { 'event_name' }

      context '#sequence_of_events_for' do
        When(:results) { test_repository.sequence_of_events_for(user: user) }
        Then { results.is_a?(ActiveRecord::Relation) }
      end

      context '#log_event!' do
        When(:result) { test_repository.log_event!(user: user, entity: entity, event_name: event_name) }
        Then { result.persisted? }
        Then { Models::EventLog.count == 1 }
      end

      context '.log_event!' do
        it 'is exposed as a module function as well' do
          expect(Models::EventLog).to receive(:create!).and_return(:created)
          described_class::Commands.log_event!(user: user, entity: entity, event_name: event_name)
        end
      end
    end
  end
end
