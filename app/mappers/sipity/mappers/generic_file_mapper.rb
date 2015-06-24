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
      MNT_PATH = Figaro.env.curate_batch_mnt_path!
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

      private

      attr_accessor :file, :repository, :work

      attr_reader :work_area

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
        json.set!(PID_KEY, namespaced_pid(file.pid))
        json.set!(AF_MODEL_KEY, CONTENT_MODEL_NAME)
        json
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
        json.set! RELS_EXT_KEY do
          json.set! CONTEXT_KEY do
            RELS_EXT_URI.each { |key, uri|   json.set!(key, uri) }
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
        content_file = File.join(curate_batch_directory, file_name_to_create)
        create_content_in(content_file)
        File.basename content_file
      end

      def curate_batch_directory
        batch_directory = MNT_PATH + '/' + "sipity-#{work.id}"
        FileUtils.mkdir_p(batch_directory) unless File.directory?(batch_directory)
        batch_directory
      end

      def mime_type
        file.file.mime_type
      end

      def date_convert(sql_date)
        if sql_date.present?
          return sql_date.to_date.strftime('%FZ')
        else
          return sql_date
        end
      end

      def create_content_in(content_file_path)
        file.file.to_file(content_file_path)
      end

      def file_name_to_create
        return file.pid + '-' + file.file_name
      end

      def decode_access_rights
        # determine and add Public, Private, Embargo and ND only rights
        decoded_access_rights = { READ_KEY => creators,  EDIT_KEY => [BATCH_USER] }
        access_rights.each do |access_right|
          case access_right
          when Models::AccessRight::OPEN_ACCESS
            decoded_access_rights[READ_GROUP_KEY] =  [PUBLIC_ACCESS]
          when Models::AccessRight::RESTRICTED_ACCESS
            decoded_access_rights[READ_GROUP_KEY] =  [ND_ONLY_ACCESS]
          when Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
            decoded_access_rights[READ_GROUP_KEY] =  [PUBLIC_ACCESS]
            decoded_access_rights[EMBARGO_KEY] = embargo_date
          when Models::AccessRight::PRIVATE_ACCESS
          end
        end
        decoded_access_rights
      end

      def embargo_date
        if file_access_rights.empty?
          embargo_dates = work.access_rights.map(&:transition_date)
        else
          embargo_dates = file.access_rights.map(&:transition_date)
        end
        embargo_dates.map { |dt| dt.strftime('%Y-%m-%d') }
        embargo_dates.to_sentence
      end

      def extract_name_for(attribute)
        Exporters::EtdExporter.etd_attributes[attribute.to_sym]
      end
    end
  end
end
