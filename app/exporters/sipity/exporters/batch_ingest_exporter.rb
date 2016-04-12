require 'sipity/exporters/batch_ingest_exporter/metadata_builder'
require 'sipity/exporters/batch_ingest_exporter/directory_mover'
require 'sipity/exporters/batch_ingest_exporter/webhook_writer'
require 'sipity/exporters/batch_ingest_exporter/metadata_writer'
require 'sipity/exporters/batch_ingest_exporter/attachment_writer'

module Sipity
  module Exporters
    # Responsible for coordinating sending a work through the batch ingest.
    class BatchIngestExporter
      DATA_PATH = Figaro.env.curate_batch_data_mount_path!

      def self.call(work:)
        new(work: work).call
      end

      def initialize(work:)
        self.work = work
      end

      private

      attr_accessor :work

      public

      def call
        AttachmentWriter.call(exporter: self)
        work_metadata = MetadataBuilder.call(exporter: self)
        MetadataWriter.call(metadata: work_metadata, exporter: self)
        WebhookWriter.call(exporter: self)
        DirectoryMover.call(exporter: self)
      end

      def data_directory
        @data_directory ||= File.join(DATA_PATH, "/sipity-#{work_id}")
      end

      def work_id
        work.to_param
      end
    end
  end
end
