require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyUsage, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { should include('usage_id') }
          its(:column_names) { should include('usage_type') }
          its(:column_names) { should include('strategy_id') }
        end
      end
    end
  end
end
