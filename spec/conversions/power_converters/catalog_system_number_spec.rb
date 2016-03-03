require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'catalog_system_number' do
    [
      ["1", "000000001"],
      ["1234567890000000", "1234567890000000"],
      ['004316606', '004316606'],
      ['4316606', '004316606'],
      [123_456, "000123456"]
    ].each_with_index do |(to_convert, expected), index|
      it "will convert #{to_convert.inspect} to #{expected.inspect} (Scenario ##{index}" do
        expect(PowerConverter.convert(to_convert, to: :catalog_system_number)).to eq(expected)
      end
    end

    [
      'A', false, 0.1
    ].each_with_index do |to_convert, index|
      it "will not convert #{to_convert.inspect} (Scenario ##{index}" do
        expect { PowerConverter.convert(to_convert, to: :catalog_system_number) }.to raise_error(PowerConverter::ConversionError)
      end

      it "will yield (and not fail) on a failed conversion of #{to_convert.inspect} (Scenario ##{index}" do
        expect(PowerConverter.convert(to_convert, to: :catalog_system_number) { 'VALUE' }).to eq('VALUE')
      end
    end
  end
end
