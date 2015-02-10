require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyStateAction, type: :model do
        subject { described_class }
        its(:column_names) { should include("originating_strategy_state_id") }
        its(:column_names) { should include("strategy_action_id") }
      end
    end
  end
end
