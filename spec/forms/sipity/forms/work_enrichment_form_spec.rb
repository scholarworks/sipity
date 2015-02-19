require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe WorkEnrichmentForm do
      let(:work) { Models::Work.new(id: '1234') }
      subject { described_class.new(work: work) }

      its(:enrichment_type) { should eq('work_enrichment') }
    end
  end
end
