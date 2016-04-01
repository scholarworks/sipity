require 'rails_helper'
require 'sipity/models/processing/strategy_action_prerequisite'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyActionPrerequisite, type: :model do
        subject { described_class }
        its(:column_names) { is_expected.to include("guarded_strategy_action_id") }
        its(:column_names) { is_expected.to include("prerequisite_strategy_action_id") }
      end
    end
  end
end
