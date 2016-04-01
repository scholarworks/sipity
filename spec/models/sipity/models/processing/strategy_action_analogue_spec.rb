require 'rails_helper'
require 'sipity/models/processing/strategy_action_analogue'

module Sipity
  module Models
    module Processing
      RSpec.describe StrategyActionAnalogue, type: :model do
        subject { described_class }
        its(:column_names) { is_expected.to include("strategy_action_id") }
        its(:column_names) { is_expected.to include("analogous_to_strategy_action_id") }

        let(:an_action) { StrategyAction.new(id: 1) }
        let(:another_action) { StrategyAction.new(id: 2) }

        it 'will not be valid with strategy_action equal to analogous_to_strategy_action' do
          expect(described_class.new(strategy_action: an_action, analogous_to_strategy_action: an_action)).to_not be_valid
        end

        it 'will be valid with strategy_action equal to analogous_to_strategy_action' do
          expect(described_class.new(strategy_action: another_action, analogous_to_strategy_action: an_action)).to be_valid
        end
      end
    end
  end
end
