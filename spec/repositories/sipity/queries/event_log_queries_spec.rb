require "rails_helper"
require 'sipity/queries/event_log_queries'

module Sipity
  module Queries
    RSpec.describe EventLogQueries, type: :isolated_repository_module do
      let(:user) { User.new(id: 1) }
      let(:entity) { Models::Work.new(id: 1) }
      let(:event_name) { 'event_name' }

      context '#sequence_of_events_for' do
        subject { test_repository.sequence_of_events_for(user: user) }
        it { is_expected.to be_a(ActiveRecord::Relation) }
      end
    end
  end
end
