require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'boolean' do
    [
      ['1', true],
      ["11", true],
      ["0", false],
      [0, false],
      [1, true],
      ['true', true],
      ['false', false],
      ['FALSE', false],
      ['Yes', true],
      ['No', false],
      ['01', true],
      ['ashdkfjahskdfadsf', true],
      ['9876543210', true],
      [nil, false],
      [Object.new, true]
    ].each_with_index do |(to_convert, expected), index|
      it "will convert #{to_convert.inspect} to #{expected} (Scenario ##{index}" do
        expect(PowerConverter.convert_to_boolean(to_convert)).to eq(expected)
      end
    end
  end
end
