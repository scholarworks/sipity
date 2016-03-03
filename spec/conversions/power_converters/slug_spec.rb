require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'slug' do
    [
      { to_convert: 'Hello World', expected: 'hello-world' },
      { to_convert: 'HelloWorld', expected: 'hello-world' },
      { to_convert: '', expected: '' },
      { to_convert: nil, expected: '' }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :slug)).to eq(scenario.fetch(:expected))
      end
    end
  end
end
