require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    RSpec.describe BatchIngestExporter do
      let(:work) { Sipity::Models::Work.new(id: '1234-56') }

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(work: work)
      end

      subject { described_class.new(work: work) }
      its(:work_id) { is_expected.to eq(work.to_param)}
      its(:data_directory) { is_expected.to match(/\/sipity-#{work.to_param}/) }
    end
  end
end
