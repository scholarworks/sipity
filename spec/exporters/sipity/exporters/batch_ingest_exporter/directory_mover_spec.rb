require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter/directory_mover'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe DirectoryMover do

        let(:exporter) { double('BatchIngestExporter', data_directory: '/tmp/sipity-1492') }
        let(:source) { exporter.data_directory }
        let(:destination) { 'tmp/queue' }
        let(:file_utility) { FileUtils::NoWrite }

        describe '#call' do
          it 'prepares the destination path' do
            expect(described_class).to receive(:prepare_destination)
            described_class.call(exporter: exporter, file_utility: file_utility)
          end

          it 'moves the data to the destination path' do
            expect(described_class).to receive(:move_files)
            described_class.call(exporter: exporter, file_utility: file_utility)
          end
        end

        describe '#prepare_destination' do
          subject { described_class.prepare_destination(path: destination) }
          # FileUtils.mkdir_p returns an array of the directories that were created
          it { is_expected.to eq(Array.wrap(destination)) }
        end

        describe '#move_files' do
          # FileUtils::NoWrite.mv always returns nil; it is difficult to verify correctness
          it 'calls the .mv method' do
            expect(file_utility).to receive(:mv)
            described_class.move_files(source: source, destination: destination, file_utility: file_utility)
          end
        end

        subject { described_class }
        its(:default_file_utility) { is_expected.to respond_to(:mv) }
        its(:default_file_utility) { is_expected.to respond_to(:mkdir_p) }
      end
    end
  end
end
