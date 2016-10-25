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
      [:hello, true],
      [Object.new, true]
    ].each_with_index do |(to_convert, expected), index|
      it "will convert #{to_convert.inspect} to #{expected} (Scenario ##{index}" do
        expect(PowerConverter.convert(to_convert, to: :boolean)).to eq(expected)
      end
    end

    [
      '', ' ', "\t", "\n"
    ].each do |to_convert|
      it "will raise an exception for #{to_convert.inspect} an empty string" do
        expect { PowerConverter.convert(to_convert, to: :boolean) }.to raise_error(PowerConverter::ConversionError)
      end
    end
  end
end
