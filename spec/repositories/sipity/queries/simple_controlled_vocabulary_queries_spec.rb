require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe SimpleControlledVocabularyQueries, type: :isolated_repository_module do
      context '#get_controlled_vocabulary_values_for_predicate_name' do
        let(:name) { 'program_name' }
        let(:value) { 'A value' }
        let(:vocab) do
          Models::SimpleControlledVocabulary.create!(
            predicate_name: name,
            predicate_value: value,
            predicate_value_code: 'A code')
        end

        it 'will get all the values associated with predicate_name' do
          vocab
          expect(test_repository.get_controlled_vocabulary_values_for_predicate_name(name: name)).to eq([value])
        end

        it 'will get records associated with predicate_name' do
          vocab
          expect(test_repository.get_controlled_vocabulary_entries_for_predicate_name(name: name)).to eq([vocab])
        end

        it 'will get controlled vocabulary value for the predicate and code' do
          vocab
          expect(test_repository.get_controlled_vocabulary_value_for(name: name, predicate_value_code: 'A code')).to eq(value)
        end

        it 'will default to the given code if nothing is found' do
          expect(test_repository.get_controlled_vocabulary_value_for(name: name, predicate_value_code: 'A code')).to eq('A code')
        end
      end
    end
  end
end
