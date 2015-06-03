require 'spec_helper'

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

      subject { described_class.new(work, repository: repository) }

      its(:default_repository) { should respond_to :work_attachments }

      its(:fedora_connection) { should include(:url, :user, :password) }

      it 'will instantiate then call the instance' do
        expect(described_class).to receive(:new).and_return(double(call: true))
        described_class.call(work)
      end

      context 'export_to_json' do
        it 'will create ROF JSON for given work' do
          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(Mappers::EtdMapper).to receive(:call).with(work).
            and_return("etd_to_json")
          expect(Mappers::GenericFileMapper).to receive(:call).with(file).
            and_return("attachment_to_json")
          expect(subject.export_to_json).to eq(["etd_to_json", "attachment_to_json"])
        end
      end

      context 'call' do
        it 'will send ROF JSON to ROF api to ingest into configured fedora' do
          expect(repository).to receive(:work_attachments).with(work: work).and_return([file])
          expect(subject).to receive(:export_to_json).
            and_return(["rof json array"])
          expect(ROF::CLI).to receive(:ingest_file)
          subject.call
        end
      end
    end
  end
end
