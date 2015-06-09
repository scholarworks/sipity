require 'optparse'
module Sipity
  # :nodoc:
  module Exporters
    # Export work from Sipity to Curate, create ROF file and download attachments
    # and bundle them to directory
    class EtdExporter
      ROF_FILE_PREFIX = 'metadata-'.freeze
      ROF_FILE_EXTN = '.rof'.freeze
      MNT_PATH = Figaro.env.curate_batch_mnt_path
      def self.call(work)
        new(work).call
      end

      def initialize(work, repository: default_repository)
        self.work = work
        self.repository = repository
        self.attachments = repository.work_attachments(work: work)
      end

      def call
        # Create rof etd file to be ingested
        file_name = ROF_FILE_PREFIX + work.id + ROF_FILE_EXTN
        FileUtils.mkdir_p(MNT_PATH) unless File.directory?(MNT_PATH)
        rof_file = File.new(File.join(MNT_PATH, file_name), 'w')
        rof_file.puts '[' + export_to_json.join(',') + ']'
        rof_file.flush
        rof_file.close
      end

      def export_to_json
        json_array = []
        json_array << Mappers::EtdMapper.call(work)
        # build attachment json
        attachments.each do |file|
          json_array << Mappers::GenericFileMapper.call(file)
        end
        json_array
      end

      private

      attr_accessor :repository, :work, :attachments

      def default_repository
        QueryRepository.new
      end
    end
  end
end
