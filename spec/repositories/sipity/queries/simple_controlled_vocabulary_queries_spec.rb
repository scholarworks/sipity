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

        before do
          vocab
        end

        it 'will get all the values associated with predicate_name' do
          expect(test_repository.get_controlled_vocabulary_values_for_predicate_name(name: name)).to eq([value])
        end

        it 'will get records associated with predicate_name' do
          expect(test_repository.get_controlled_vocabulary_entries_for_predicate_name(name: name)).to eq([vocab])
        end
      end
    end
  end
end
