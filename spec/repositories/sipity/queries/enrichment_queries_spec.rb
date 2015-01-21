require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe EnrichmentQueries, type: :repository_methods do
      context '#build_create_describe_work_form' do
        let(:work) { double }
        subject { test_repository.build_create_describe_work_form(work: work) }

        it { should respond_to :work }
        it { should respond_to :submit }
        it { should respond_to :valid? }
        it { should respond_to :abstract }
      end

      context '#build_enrichment_form' do
        let(:work) { double }
        let(:valid_enrichment_type) { 'attach' }
        let(:invalid_enrichment_type) { '__very_much_not_valid__' }
        context 'with valid enrichment type' do
          subject { test_repository.build_enrichment_form(work: work, enrichment_type: valid_enrichment_type) }
          it { should respond_to :work }
          it { should respond_to :submit }
          it { should respond_to :valid? }
        end
        context 'with invalid enrichment type' do
          it 'will raise an exception' do
            expect { test_repository.build_enrichment_form(work: work, enrichment_type: invalid_enrichment_type) }.
              to raise_error(Exceptions::EnrichmentNotFoundError)
          end
        end
      end
    end
  end
end
