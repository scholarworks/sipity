require 'spec_helper'

module Sipity
  module Repo
    RSpec.describe EventLogMethods, type: :repository_methods do
      context '#sequence_of_events_for' do
        Given(:user) { User.new(id: 1) }
        When(:results) { test_repository.sequence_of_events_for(user: user) }
        Then { results.is_a?(ActiveRecord::Relation) }
      end
    end
  end
end
