require 'spec_helper'
require 'sipity/queries/event_log_queries'

module Sipity
  module Queries
    RSpec.describe EventLogQueries, type: :isolated_repository_module do
      let(:user) { Models::IdentifiableAgent.new_from_netid(netid: 'hworld') }
      let(:entity) { Models::Work.new(id: 1) }
      let(:event_name) { 'event_name' }

      context '#sequence_of_events_for' do
        subject { test_repository.sequence_of_events_for(user: user) }
        it { should be_a(ActiveRecord::Relation) }
      end
    end
  end
end
