require 'spec_helper'

module Sipity
  module Queries
    RSpec.describe EventLogQueries, type: :isolated_repository_module do
      Given(:user) { User.new(id: 1) }
      Given(:entity) { Models::Work.new(id: 1) }
      Given(:event_name) { 'event_name' }

      context '#sequence_of_events_for' do
        When(:results) { test_repository.sequence_of_events_for(user: user) }
        Then { results.is_a?(ActiveRecord::Relation) }
      end
    end
  end
end
