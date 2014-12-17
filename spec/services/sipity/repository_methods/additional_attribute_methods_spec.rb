require 'spec_helper'

module Sipity
  module RepositoryMethods
    RSpec.describe AdditionalAttributeMethods, type: :repository_methods do
      # Because of enum enforcement I need real key names
      let(:key) { Models::AdditionalAttribute::CITATION_PREDICATE_NAME }
      let(:key_2) { Models::AdditionalAttribute::PUBLISHER_PREDICATE_NAME }
      let(:header) { Models::Header.new(id: '123') }

      subject { test_repository }

      it 'will create a key/value pair if the value does not exist' do
        expect { subject.update_header_attribute_values!(header: header, key: key, values: 'abc') }.
          to change { subject.header_attribute_values_for(header: header, key: key) }.from([]).to(['abc'])
      end

      it 'will destroy_header_attribute_values a key/value pair if the value exists but is not part of the update' do
        subject.create_header_attribute_values!(header: header, key: key, values: 'abc')
        subject.update_header_attribute_values!(header: header, key: key, values: 'new_value')
        expect(subject.header_attribute_values_for(header: header, key: key)).to eq(['new_value'])
      end

      it 'will leave untouched a key/value pair if the key/value exists' do
        subject.create_header_attribute_values!(header: header, key: key, values: ['abc', 'def'])
        subject.update_header_attribute_values!(header: header, key: key, values: ['new_value', 'def'])
        expect(subject.header_attribute_values_for(header: header, key: key)).to eq(['def', 'new_value'])
      end

      it 'will handle mixed key/value pairs' do
        subject.create_header_attribute_values!(header: header, key: key, values: ['abc', 'def'])
        subject.create_header_attribute_values!(header: header, key: key_2, values: ['abc', 'def'])
        subject.update_header_attribute_values!(header: header, key: key, values: ['new_value', 'def'])
        expect(subject.header_attribute_key_value_pairs(header: header)).
          to eq([[key, 'def'], [key, 'new_value'], [key_2, 'abc'], [key_2, 'def']])

        # Limiting to a subset of keys
        expect(subject.header_attribute_key_value_pairs(header: header, keys: [key])).
          to eq([[key, 'def'], [key, 'new_value']])
      end

      it 'will not destroy_header_attribute_values when no values are specified' do
        subject.create_header_attribute_values!(header: header, key: key, values: ['abc'])
        subject.destroy_header_attribute_values!(header: header, key: key, values: [])
        expect(subject.header_attribute_values_for(header: header, key: key)).to eq(['abc'])
      end

      its(:header_default_attribute_keys_for) { should be_a(Array) }
    end
  end
end
