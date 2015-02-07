require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyActionPrerequisite, type: :model do
        subject { described_class }
        its(:column_names) { should include("guarded_strategy_action_id") }
        its(:column_names) { should include("prerequisite_strategy_action_id") }
      end
    end
  end
end
