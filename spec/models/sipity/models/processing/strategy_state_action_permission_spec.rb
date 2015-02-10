require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyStateActionPermission, type: :model do
        subject { described_class }
        its(:column_names) { should include("strategy_role_id") }
        its(:column_names) { should include("strategy_state_action_id") }
      end
    end
  end
end
