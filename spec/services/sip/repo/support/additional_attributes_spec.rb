require 'spec_helper'

module Sip
  module Repo
    module Support
      RSpec.describe AdditionalAttributes do
        let(:header) { Header.new(id: '123') }

        it 'will create a key/value pair if the value does not exist' do
          expect { subject.update!(header: header, key: 'key', values: 'abc') }.
            to change { subject.values_for(header: header, key: 'key') }.from([]).to(['abc'])
        end

        it 'will destroy a key/value pair if the value exists but is not part of the update' do
          subject.create!(header: header, key: 'key', values: 'abc')
          subject.update!(header: header, key: 'key', values: 'new_value')
          expect(subject.values_for(header: header, key: 'key')).to eq(['new_value'])
        end

        it 'will leave untouched a key/value pair if the key/value exists' do
          subject.create!(header: header, key: 'key', values: ['abc', 'def'])
          subject.update!(header: header, key: 'key', values: ['new_value', 'def'])
          expect(subject.values_for(header: header, key: 'key')).to eq(['def', 'new_value'])
        end

        it 'will handles mixed key/value pairs' do
          subject.create!(header: header, key: 'key', values: ['abc', 'def'])
          subject.create!(header: header, key: 'key_2', values: ['abc', 'def'])
          subject.update!(header: header, key: 'key', values: ['new_value', 'def'])
          expect(subject.key_value_pairs_for(header: header)).
            to eq([['key', 'def'], ['key', 'new_value'], ['key_2', 'abc'], ['key_2', 'def']])
        end

        it 'will not destroy when no values are specified' do
          subject.create!(header: header, key: 'key', values: ['abc'])
          subject.destroy!(header: header, key: 'key', values: [])
          expect(subject.values_for(header: header, key: 'key')).to eq(['abc'])
        end

        its(:default_keys_for) { should be_a(Array) }
      end
    end
  end
end
