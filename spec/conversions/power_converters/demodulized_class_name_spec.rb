require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context "demodulized_class_name" do
    [
      { to_convert: 'Hello World', expected: 'HelloWorld' },
      { to_convert: 'HelloWorld', expected: 'HelloWorld' },
      { to_convert: 'HelloWorlds', expected: 'HelloWorld' },
      { to_convert: nil, expected: '' },
      { to_convert: 'hello World/Somebody', expected: 'HelloWorldSomebody' }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :demodulized_class_name)).to eq(scenario.fetch(:expected))
      end
    end
  end
end
