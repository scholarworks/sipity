require 'rails_helper'
require 'sipity/models/processing/strategy_responsibility'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyResponsibility, type: :model do
        subject { described_class }
        its(:column_names) { is_expected.to include('actor_id') }
        its(:column_names) { is_expected.to include('strategy_role_id') }
      end
    end
  end
end
