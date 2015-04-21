require 'rails_helper'

RSpec.describe 'power converters' do
  context 'boolean' do
    [
      ['1', true],
      ["11", true],
      ["0", false],
      [0, false],
      [1, true],
      ['true', true],
      ['false', false],
      [nil, false],
      [Object.new, true]
    ].each_with_index do |(to_convert, expected), index|
      it "will convert #{to_convert.inspect} to #{expected} (Scenario ##{index}" do
        expect(PowerConverter.convert_to_boolean(to_convert)).to eq(expected)
      end
    end
  end

  context 'strategy_state' do
    let(:strategy_state) { Sipity::Models::Processing::StrategyState.new(id: 1, name: 'hello') }
    let(:strategy) { Sipity::Models::Processing::Strategy.new(id: 2, name: 'strategy') }
    it 'will convert a Processing::Model::StrategyState' do
      expect(PowerConverter.convert(strategy_state, to: :strategy_state)).to eq(strategy_state)
    end

    it 'will convert a string based on scope' do
      Sipity::Models::Processing::StrategyState.create!(strategy_id: strategy.id, name: 'hello')
      PowerConverter.convert('hello', scope: strategy, to: :strategy_state)
    end

    it 'will attempt convert a string based on scope' do
      expect { PowerConverter.convert('missing', scope: strategy, to: :strategy_state) }.
        to raise_error(PowerConverter::ConversionError)
    end
  end
end
