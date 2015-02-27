require 'spec_helper'

module Sipity
  module Conversions
    describe ConvertToBoolean do
      include ::Sipity::Conversions::ConvertToBoolean

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call('1')).to eq(true)
        end
      end

      context '.convert_to_boolean' do
        it 'will be private' do
          expect { described_class.convert_to_boolean(true) }.
            to raise_error(NoMethodError, /private method `convert_to_boolean'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_boolean' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_boolean)
        end

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
            expect(convert_to_boolean(to_convert)).to eq(expected)
          end
        end
      end
    end
  end
end
