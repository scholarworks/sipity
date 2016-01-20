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
      # Properties keys
      PROPERTIES_METADATA_KEY = 'properties-meta'.freeze
      PROPERTIES_KEY = 'properties'.freeze
      # Access Rights keys
      ACCESS_RIGHTS_KEY = 'rights'.freeze
      PUBLIC_ACCESS = 'public'.freeze
      ND_ONLY_ACCESS = 'restricted'.freeze
      READ_KEY = 'read'.freeze
      EDIT_KEY = 'edit'.freeze
      READ_GROUP_KEY = 'read-groups'.freeze
      EMBARGO_KEY = 'embargo-date'.freeze
      # RELS-EXT KEYS
      RELS_EXT_KEY = 'rels-ext'.freeze
      RELS_EXT_URI = {
        "hydramata-rel" => "http://projecthydra.org/ns/relations#"
      }.freeze
      PARENT_PREDICATE_KEY = 'isPartOf'.freeze
      EDITOR_PREDICATE_KEY = 'hydramata-rel:hasEditor'.freeze
      EDITOR_GROUP_PREDICATE_KEY = 'hydramata-rel:hasEditorGroup'.freeze

      def self.call(attachment, **keywords)
        new(attachment, **keywords).call
      end

      def initialize(attachment, **keywords)
        self.file = attachment
        self.work = attachment.work
        extract_keywords(**keywords)
      end

      def call
        build_json
      end

      private

      def extract_keywords(repository: default_repository, attribute_map: default_attribute_map, mount_data_path: default_mount_data_path)
        self.repository = repository
        self.attribute_map = attribute_map
        self.mount_data_path = mount_data_path
      end

      attr_accessor :file, :repository, :work, :attribute_map, :mount_data_path

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

      def default_repository
        QueryRepository.new
      end

      def namespaced_pid(id)
        NAMESPACE + id
      end

      def attributes
        { title: file.file_name, creator: creators, date_uploaded: date_convert(file.created_at),
          date_modified: date_convert(file.updated_at) }
      end

      def file_access_rights
        @file_access_rights ||= repository.attachment_access_right(attachment: file)
      end

      def file_access_right_code
        file_access_rights.access_right_code
      end
      alias access_right_code file_access_right_code

      def creators
        @creators ||= repository.scope_creating_users_for_entity(entity: work).map(&:username)
      end

      def gather_attachment_metadata(json)
        json.set!(TYPE_KEY, "fobject")
        json.set!(PID_KEY, namespaced_pid(file.pid))
        json.set!(AF_MODEL_KEY, CONTENT_MODEL_NAME)
        json
      end

      def transform_attributes_to_metadata(json)
        json.set! DESC_METADATA_KEY do
          json.set! CONTEXT_KEY do
            TERM_URI.each { |key, uri| json.set!(key, uri) }
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
        json.set! RELS_EXT_KEY do
          json.set! CONTEXT_KEY do
            RELS_EXT_URI.each { |key, uri| json.set!(key, uri) }
          end
          json.set!(EDITOR_PREDICATE_KEY, [Figaro.env.curate_batch_user_pid!])
          json.set!(EDITOR_GROUP_PREDICATE_KEY, [Figaro.env.curate_batch_group_pid!])
          json.set!(PARENT_PREDICATE_KEY, [namespaced_pid(work.id)])
        end
      end

      def content_datastream(json)
        file_name = create_content_from_attachment
        json.set! 'content-meta'.to_sym do
          json.set!('mime-type', mime_type)
          json.set!('label', file.file_name)
        end
        json.set!('content-file', file_name)
      end

      def create_content_from_attachment
        create_directory(curate_data_directory)
        content_file = File.join(curate_data_directory, file_name_to_create)
        create_content_in(content_file)
        File.basename content_file
      end

      def curate_data_directory
        File.join(mount_data_path, "sipity-#{work.id}")
      end

      def create_directory(directory)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
        directory
      end

      def mime_type
        file.file.mime_type
      end

      def date_convert(sql_date)
        return sql_date.to_date.strftime('%FZ') if sql_date.present?
        sql_date
      end

      def create_content_in(content_file_path)
        file.file.to_file(content_file_path)
      end

      def file_name_to_create
        return file.pid + '-' + file.file_name
      end

      def decode_access_rights
        # determine and add Public, Private, Embargo and ND only rights
        decoded_access_rights = { READ_KEY => creators, EDIT_KEY => [BATCH_USER] }
        case access_right_code
        when Models::AccessRight::OPEN_ACCESS
          decoded_access_rights[READ_GROUP_KEY] = [PUBLIC_ACCESS]
        when Models::AccessRight::RESTRICTED_ACCESS
          decoded_access_rights[READ_GROUP_KEY] = [ND_ONLY_ACCESS]
        when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
          decoded_access_rights[READ_GROUP_KEY] = [PUBLIC_ACCESS]
          decoded_access_rights[EMBARGO_KEY] = embargo_date
        when Models::AccessRight::PRIVATE_ACCESS
        end
        decoded_access_rights
      end

      def embargo_date
        embargo_dt = file_access_rights.transition_date
        embargo_dt.strftime('%Y-%m-%d')
      end

      def extract_name_for(attribute)
        attribute_map.fetch(attribute.to_sym)
      end

      def default_attribute_map
        require 'sipity/exporters/etd_exporter' unless defined?(Exporters::EtdExporter::ETD_ATTRIBUTES)
        Exporters::EtdExporter::ETD_ATTRIBUTES
      end

      def default_mount_data_path
        require 'sipity/exporters/etd_exporter' unless defined?(Exporters::EtdExporter::MNT_DATA_PATH)
        Exporters::EtdExporter::MNT_DATA_PATH
      end
    end
  end
end
