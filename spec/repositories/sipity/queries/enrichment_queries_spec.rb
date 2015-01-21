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
        subject { test_repository.build_enrichment_form(work: work) }

        it { should respond_to :work }
        it { should respond_to :submit }
        it { should respond_to :valid? }
        it { should respond_to :files }
      end
    end
  end
end
