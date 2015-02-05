require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyState, type: :model do
        subject { described_class }
        its(:column_names) { should include("strategy_id") }
        its(:column_names) { should include("name") }
      end
    end
  end
end
