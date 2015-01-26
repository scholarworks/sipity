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
    end
  end
end
