require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyActionAnalogue, type: :model do
        subject { described_class }
        its(:column_names) { should include("strategy_action_id") }
        its(:column_names) { should include("analogous_to_strategy_action_id") }
      end
    end
  end
end
