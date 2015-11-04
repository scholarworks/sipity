require 'spec_helper'
require 'sipity/exporters/etd_exporter'

module Sipity
  module Exporters
    RSpec.describe EtdExporter do
      let(:access_right) { ['private_access'] }
      let(:work) { double }
      let(:repository) { QueryRepositoryInterface.new }
      let(:creators) { [double(username: 'Hello')] }
      let(:title) { 'Title of the work' }
      let(:batch_user) { 'curate_batch_user' }
      let(:file) { double }
      let(:json_array) { ["etd_to_json", "attachment_to_json"] }

      subject { described_class.new(work, repository: repository) }

      its(:default_repository) { should respond_to :work_attachments }

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      context 'export_to_json' do
        it 'will create ROF JSON for given work' do
          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(Mappers::EtdMapper).to receive(:call).with(work, attribute_map: kind_of(Hash), mount_data_path: kind_of(String)).
            and_return("etd_to_json")
          expect(Mappers::GenericFileMapper).to receive(:call).with(file, attribute_map: kind_of(Hash), mount_data_path: kind_of(String)).
            and_return("attachment_to_json")
          expect(subject.export_to_json).to eq(json_array)
        end
      end

      context 'call' do
        it 'will send ROF JSON to ROF api to ingest into configured fedora' do
          allow(work).to receive(:id).and_return('a_id')
          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(subject).to receive(:export_to_json).
            and_return(["rof json array"])
          expect(FileUtils).to receive(:mv)
          subject.call
        end
      end
    end
  end
end
