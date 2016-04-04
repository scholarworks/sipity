require 'rails_helper'
require 'sipity/models/processing/strategy_role'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyRole, type: :model do
        subject { described_class }
        its(:column_names) { is_expected.to include('strategy_id') }
        its(:column_names) { is_expected.to include('role_id') }
      end
    end
  end
end
