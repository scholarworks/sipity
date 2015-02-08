require 'rails_helper'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyRole, type: :model do
        subject { described_class }
        its(:column_names) { should include('strategy_id') }
        its(:column_names) { should include('role_id') }
      end
    end
  end
end