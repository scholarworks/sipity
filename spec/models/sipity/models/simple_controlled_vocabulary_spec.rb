require 'rails_helper'

module Sipity
  module Models
    RSpec.describe SimpleControlledVocabulary, type: :model do
      context 'data structure' do
        subject { described_class }
        its(:column_names) { should include('predicate_name') }
        its(:column_names) { should include('predicate_value') }
        its(:column_names) { should include('predicate_value_code') }
      end

      subject { described_class.new }
      it 'will raise an ArgumentError if you provide an invalid predicate_name' do
        expect { subject.predicate_name = '__incorrect_strategy__' }.to raise_error(ArgumentError)
      end
    end
  end
end
