require 'rails_helper'
require 'sipity/models/processing/strategy_usage'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyUsage, type: :model do
        context 'database configuration' do
          subject { described_class }
          its(:column_names) { is_expected.to include('usage_id') }
          its(:column_names) { is_expected.to include('usage_type') }
          its(:column_names) { is_expected.to include('strategy_id') }
        end
      end
    end
  end
end
