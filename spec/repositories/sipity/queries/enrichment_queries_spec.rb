require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe EnrichmentQueries, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 123) }
      let(:work_area) { Models::WorkArea.new(slug: 'etd', demodulized_class_prefix_name: 'Etd') }

      context '#build_enrichment_form' do
        let(:valid_enrichment_type) { 'attach' }
        before { allow(work).to receive(:work_area).and_return(work_area) }
        context 'with valid enrichment type (to demonstrate collaboration)' do
          subject do
            test_repository.build_enrichment_form(work: work, enrichment_type: valid_enrichment_type, representative_attachment_id: '1')
          end
          it { should respond_to :work }
          it { should respond_to :submit }
          it { should respond_to :valid? }
        end
      end
    end
  end
end
