require 'spec_helper'
require 'sipity/data_generators/schema_validator'

module Sipity
  RSpec.describe DataGenerators::SchemaValidator do
    context '.call' do
      let(:data) { { name: 'Hello' } }

      context 'with expected schema interface' do
        it 'returns true if the given data has a valid schema' do
          schema = double(call: double(messages: {}))
          expect(described_class.call(data: data, schema: schema)).to eq(true)
        end

        it 'raises an exception with messages if the given data has an invalid schema' do
          schema = double(call: double(messages: { key: 'error' }))
          expect { described_class.call(data: data, schema: schema) }.to raise_error(Exceptions::InvalidSchemaError)
        end
      end

      context 'with a dry-validation schema' do
        let(:schema) do
          Class.new(Dry::Validation::Schema) do
            key(:name, &:str?)
          end.new
        end

        it 'returns true if the given data has a valid schema' do
          expect(described_class.call(data: { name: 'Hello' }, schema: schema)).to eq(true)
        end

        it 'raises an exception with messages if the given data has an invalid schema' do
          expect { described_class.call(data: {}, schema: schema) }.to raise_error(Exceptions::InvalidSchemaError)
        end
      end
    end
  end
end
