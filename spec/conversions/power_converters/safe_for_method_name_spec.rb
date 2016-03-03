require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'safe_for_method_name' do
    [
      { to_convert: 'Hello World', expected: 'hello_world' },
      { to_convert: 'HelloWorld', expected: 'hello_world' }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :safe_for_method_name)).to eq(scenario.fetch(:expected))
      end
    end

    [
      ''
    ].each do |to_convert_but_will_fail|
      it "will fail to convert #{to_convert_but_will_fail.inspect}" do
        expect { PowerConverter.convert(to_convert_but_will_fail, to: :safe_for_method_name) }.to(
          raise_error(PowerConverter::ConversionError)
        )
      end
    end
  end
end
