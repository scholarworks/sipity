module Sipity
  # :nodoc:
  module Mappers
    # Mapper to map etd work into descMetadata
    class GenericFileMapper
      CONTENT_MODEL_NAME = 'GenericFile'.freeze
      NAMESPACE = 'und:'.freeze
      BATCH_USER = 'curate_batch_user'.freeze
      TERM_URI = {
        dc: 'http://purl.org/dc/terms/',
        rdfs: 'http://www.w3.org/2000/01/rdf-schema#'
      }.freeze
      PID_KEY = 'pid'.freeze
      TYPE_KEY = 'type'.freeze
      CONTEXT_KEY = '@context'.freeze
      AF_MODEL_KEY = 'af-model'.freeze
      DESC_METADATA_KEY = 'metadata'.freeze
      ACCESS_RIGHTS_KEY = 'rights'.freeze
      PROPERTIES_METADATA_KEY = 'properties-meta'.freeze
      PROPERTIES_KEY = 'properties'.freeze
      RELS_EXT_KEY = 'rels-ext'.freeze
      PREDICATE_KEY = 'isPartOf'.freeze
      PUBLIC_ACCESS = 'public'.freeze
      ND_ONLY_ACCESS = 'restricted'.freeze
      READ_KEY = 'read'.freeze
      READ_GROUP_KEY = 'read-groups'.freeze
      EMBARGO_KEY = 'embargo-date'.freeze

      def self.call(attachment)
        new(attachment).call
      end

      def initialize(attachment, repository: default_repository)
        self.file = attachment
        self.repository = repository
        self.work = attachment.work
      end

      def call
        build_json
      end

      def build_json
        Jbuilder.encode do |json|
          gather_attachment_metadata(json)
          json.set!(ACCESS_RIGHTS_KEY, decode_access_rights)
          transform_attributes_to_metadata(json)
          rels_ext_datastream(json)
          properties_meta(json)
          properties_datastream(json)
          content_datastream(json)
        end
      end

      private

      attr_accessor :file, :repository, :work

      attr_reader :work_area

      def default_repository
        QueryRepository.new
      end

      def append_namespace_to_id(id)
        NAMESPACE + id
      end

      def attributes
        { title: file.file_name, creator: creators, date_uploaded: file.created_at, date_modified: file.updated_at }
      end

      def file_access_rights
        @file_access_rights ||= repository.attachment_access_right_codes(attachment: file)
      end

      def work_access_rights
        @work_access_rights ||= repository.work_access_right_codes(work: work)
      end

      def access_rights
        @access_rights =  file_access_rights.empty? ? work_access_rights : file_access_rights
      end

      def creators
        @creators ||= repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER).map(&:username)
      end

      def gather_attachment_metadata(json)
        json.set!(TYPE_KEY, "fobject")
        json.set!(PID_KEY, append_namespace_to_id(file.pid))
        json.set!(AF_MODEL_KEY, CONTENT_MODEL_NAME)
      end

      def transform_attributes_to_metadata(json)
        json.set! DESC_METADATA_KEY do
          json.set! CONTEXT_KEY do
            TERM_URI.each { |key, uri|   json.set!(key, uri) }
          end
          attributes.each do |key, value|
            json.set!(extract_name_for(key), value)
          end
        end
      end

      def properties_meta(json)
        json.set! PROPERTIES_METADATA_KEY.to_sym do
          json.set!('mime-type', 'text/xml')
        end
      end

      def properties_datastream(json)
        json.set!(PROPERTIES_KEY, "<fields><depositor>#{BATCH_USER}</depositor></fields>")
      end

      def rels_ext_datastream(json)
        json.set! 'rels-ext'.to_sym do
          json.set!(PREDICATE_KEY, [append_namespace_to_id(work.id)])
        end
      end

      def content_datastream(json)
        json.set! 'content-meta'.to_sym do
          json.set!('mime-type', mime_type)
          json.set!('label', file.file_name)
        end
        json.set!('content-file', file.file_uid)
      end

      def mime_type
        file.file.mime_type
      end

      def decode_access_rights
        # determine and add Public, Private, Embargo and ND only rights
        access_rights.each do |access_right|
          case access_right
          when Models::AccessRight::OPEN_ACCESS
            return [ {READ_GROUP_KEY => [PUBLIC_ACCESS], READ_KEY => [creators]} ]
          when Models::AccessRight::RESTRICTED_ACCESS
            return [ {READ_GROUP_KEY => [ND_ONLY_ACCESS], READ_KEY => [creators]} ]
          when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
             return [ {EMBARGO_KEY => embargo_date, READ_KEY => [creators]} ]
          when Models::AccessRight::PRIVATE_ACCESS
            return [ { READ_KEY => [creators] }]
          end
        end
      end

      def embargo_date
        if file_access_rights.empty?
          embargo_dates = work.access_rights.pluck(:transition_date)
        else
          embargo_dates = file.access_rights.pluck(:transition_date)
        end
        embargo_dates.map { |dt| dt.strftime('%Y-%m-%d') if dt.present? }
      end

      def extract_name_for(attribute)
        ETD_ATTRIBUTES[attribute.to_s]
      end
    end
  end
end
