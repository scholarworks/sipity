require "rails_helper"
require 'sipity/conversions/convert_to_processing_strategy_id'

module Sipity
  module Conversions
    describe ConvertToProcessingStrategyId do
      include ::Sipity::Conversions::ConvertToProcessingStrategyId

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call(123)).to eq(123)
        end
      end

      context '.convert_to_processing_strategy_id' do
        it 'will be private' do
          object = double(to_processing_entity: 1234)
          expect { described_class.convert_to_processing_strategy_id(object) }.
            to raise_error(NoMethodError, /private method `convert_to_processing_strategy_id'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_processing_strategy_id' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_processing_strategy_id)
        end

        [
          [Models::Processing::Strategy.new(id: 12), 12],
          ["11", 11],
          [2, 2],
          [Models::Processing::Entity.new(strategy_id: 37), 37]
        ].each_with_index do |(to_convert, expected), index|
          it "will convert #{to_convert.inspect} to #{expected} (Scenario ##{index}" do
            expect(convert_to_processing_strategy_id(to_convert)).to eq(expected)
          end
        end

        it "will convert a processing entity to a strategy" do
          to_convert = double(to_processing_entity: double(strategy_id: 1))
          expect(convert_to_processing_strategy_id(to_convert)).to eq(1)
        end

        it "will fail if the to_processing_entity fails a processing entity to a strategy" do
          to_convert = double(to_processing_entity: double)
          expect { convert_to_processing_strategy_id(to_convert) }.to raise_error(Exceptions::ProcessingStrategyIdConversionError)
        end

        it 'will raise an exception if it cannot convert' do
          expect { convert_to_processing_strategy_id(double) }.to raise_error(Exceptions::ProcessingStrategyIdConversionError)
        end
      end
    end
  end
end
