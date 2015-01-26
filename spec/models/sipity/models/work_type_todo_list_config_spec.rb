require 'rails_helper'
module Sipity
  module Models
    RSpec.describe WorkTypeTodoListConfig, type: :model do
      context 'data structure' do
        subject { described_class }
        its(:column_names) { should include('work_type') }
        its(:column_names) { should include('work_processing_state') }
        its(:column_names) { should include('enrichment_type') }
        its(:column_names) { should include('enrichment_group') }
      end

      subject { described_class.new }
      it 'will raise an ArgumentError if you provide an invalid enrichment_group' do
        expect { subject.enrichment_group = '__invalid_enrichment_group__' }.to raise_error(ArgumentError)
      end
    end
  end
end
