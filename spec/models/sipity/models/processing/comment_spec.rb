require 'rails_helper'
require 'sipity/models/processing/comment'

module Sipity
  module Models
    module Processing
      RSpec.describe Comment do

        context 'database configuration' do
          subject { described_class }
          its(:column_names) { should include('entity_id') }
          its(:column_names) { should include('actor_id') }
          its(:column_names) { should include('comment') }
          its(:column_names) { should include('originating_strategy_action_id') }
          its(:column_names) { should include('originating_strategy_state_id') }
          its(:column_names) { should include('stale') }
        end

        subject { described_class.new }
        it { should_not respond_to(:name_of_commentor) }
      end
    end
  end
end
