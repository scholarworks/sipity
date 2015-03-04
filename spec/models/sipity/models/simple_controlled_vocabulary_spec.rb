require 'rails_helper'

module Sipity
  module Models
    RSpec.describe SimpleControlledVocabulary, type: :model do
      context 'data structure' do
        subject { described_class }
        its(:column_names) { should include('predicate_name') }
        its(:column_names) { should include('predicate_value') }
      end
    end
  end
end
