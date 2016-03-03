require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'file_system_safe_file_name' do
    [
      { to_convert: 'Hello World', expected: 'hello_world' },
      { to_convert: 'HelloWorld', expected: 'hello_world' },
      { to_convert: '', expected: '' },
      { to_convert: nil, expected: '' }
    ].each do |scenario|
      it "will convert #{scenario.fetch(:to_convert)} to #{scenario.fetch(:expected)}" do
        expect(PowerConverter.convert(scenario.fetch(:to_convert), to: :file_system_safe_file_name)).to eq(scenario.fetch(:expected))
      end
    end
  end
end
