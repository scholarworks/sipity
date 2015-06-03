require 'rof'
require 'optparse'
module Sipity
  # :nodoc:
  module Exporters
    # Export work from Sipity to Curate, create ROF file and download attachments
    # and bundle them to directory
    class EtdExporter
      ROF_FILE_NAME = 'etd_rof.json'.freeze

      def self.call(work)
        new(work).call
      end

      def initialize(work, repository: default_repository)
        self.work = work
        self.repository = repository
        self.attachments = repository.work_attachments(work: work)
        self.rof_file = File.new(File.join(Rails.root, 'tmp', ROF_FILE_NAME), 'w')
      end

      def call
        # Create rof etd file to be ingested
        etd_data = '[' + export_to_json.join(',') + ']'
        rof_file.puts etd_data
        rof_file.flush
        rof_file.close
        # Ingest into fedora
        ROF::CLI.ingest_file(rof_file, ["."], STDOUT, fedora_connection)
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

      attr_accessor :repository, :work, :attachments, :rof_file

      def default_repository
        QueryRepository.new
      end

      def fedora_connection
        return @fedora_info if @fedora_info.present?
        @fedora_info = {}
        @fedora_info[:url] = Figaro.env.fedora_url!
        @fedora_info[:user] = Figaro.env.fedora_user!
        @fedora_info[:password] = Figaro.env.fedora_password!
        @fedora_info
      end
    end
  end
end
