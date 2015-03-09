require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe SimpleControlledVocabularyQueries, type: :isolated_repository_module do
      context '#get_values_by_predicate_name' do
        let(:name) { 'program_name' }
        let(:value) { 'A value' }
        before do
          Models::SimpleControlledVocabulary.create!(predicate_name: name,
                                                     predicate_value: value,
                                                     predicate_value_code: 'A code')
        end
        it 'will get all the values associated with predicate_name' do
          expect(test_repository.get_values_by_predicate_name(name: name)).to eq([value])
        end
      end
    end
  end
end
