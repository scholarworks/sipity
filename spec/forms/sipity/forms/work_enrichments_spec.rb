require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkEnrichments do
      context '#find_enrichment_form_builder' do
        let(:valid_enrichment_type) { 'attach' }
        let(:invalid_enrichment_type) { '__very_much_not_valid__' }
        context 'with valid enrichment type' do
          subject { described_class.find_enrichment_form_builder(enrichment_type: valid_enrichment_type) }
          it { should eq(WorkEnrichments::AttachForm) }
          it { should respond_to(:new) }
        end
        context 'with invalid enrichment type' do
          it 'will raise an exception' do
            expect { described_class.find_enrichment_form_builder(enrichment_type: invalid_enrichment_type) }.
              to raise_error(Exceptions::EnrichmentNotFoundError)
          end
        end
      end
    end
  end
end
