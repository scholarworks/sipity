require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe EnrichmentQueries, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 123) }

      context '#build_enrichment_form' do
        let(:valid_enrichment_type) { 'attach' }
        context 'with valid enrichment type (to demonstrate collaboration)' do
          subject { test_repository.build_enrichment_form(work: work, enrichment_type: valid_enrichment_type) }
          it { should respond_to :work }
          it { should respond_to :submit }
          it { should respond_to :valid? }
        end
      end
    end
  end
end
