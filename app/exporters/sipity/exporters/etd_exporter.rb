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
      ETD_ATTRIBUTES = {
        creator: "dc:creator",
        title: "dc:title",
        alternate_title: "dc:title#alternate",
        subject: "dc:subject",
        abstract: "dc:description#abstract",
        country: "dc:publisher#country",
        advisor: "ths:relators",
        contributor: "dc:contributor",
        contributor_role: "ms:role",
        date_created: "dc:date#created",
        date_uploaded: "dc:dateSubmitted",
        date_modified: "dc:modified",
        language: "dc:language",
        copyright: "dc:rights",
        note: "dc:description#note",
        publisher: "dc:publisher",
        temporal_coverage: "dc:coverage#temporal",
        spatial_coverage: "dc:coverage#spatial",
        identifier: "dc:identifier#doi",
        urn: "dc:identifier#other",
        defense_date: "dc:date",
        date_approved: "dc:date#approved",
        degree: "ms:degree",
        degree_name: "ms:name",
        program_name: "ms:discipline",
        degree_level: "ms:level"
      }

      def self.etd_attributes
        ETD_ATTRIBUTES
      end

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
        File.open(File.join(MNT_PATH, file_name), 'w+') do |rof_file|
          rof_file.puts '[' + export_to_json.join(',') + ']'
        end
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
