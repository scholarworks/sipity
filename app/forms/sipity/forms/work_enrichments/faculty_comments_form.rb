module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for faculty comments
      class FacultyCommentsForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          initialize_non_attachement_attributes(attributes)
          initialize_file_attributes(attributes)
        end

        attr_accessor :files, :course, :nature_of_supervision, :quality_of_research, :use_of_library_resources
        private(:files=, :course=, :nature_of_supervision=, :quality_of_research=, :use_of_library_resources=)

        attr_reader :supervising_semester

        validates :course, presence: true
        validates :nature_of_supervision, presence: true
        validates :quality_of_research, presence: true
        validates :use_of_library_resources, presence: true

        include Hydra::Validations
        validates :supervising_semester, presence: true

        def attachments
          @attachments ||= attachments_from_work
        end

        # Exposed so that field_for will work
        def attachments_attributes=(value)
          collect_files_for_deletion_and_update(value)
        end

        private

        def initialize_non_attachement_attributes(attributes)
          self.course = attributes.fetch(:course) { retrieve_from_work(key: 'course') }
          self.nature_of_supervision = attributes.fetch(:nature_of_supervision) { retrieve_from_work(key: 'nature_of_supervision') }
          self.supervising_semester = attributes.fetch(:supervising_semester) { retrieve_from_work(key: 'supervising_semester') }
          self.quality_of_research = attributes.fetch(:quality_of_research) { retrieve_from_work(key: 'quality_of_research') }
          self.use_of_library_resources = attributes.fetch(:use_of_library_resources) do
            retrieve_from_work(key: 'use_of_library_resources')
          end
        end

        def initialize_file_attributes(attributes)
          self.files = attributes[:files]
          self.attachments_attributes = attributes.fetch(:attachments_attributes, {})
        end

        def supervising_semester=(values)
          @supervising_semester = to_array_without_empty_values(values)
        end

        def save(requested_by:)
          super do
            update_course
            update_nature_of_supervision
            update_supervising_semester
            update_quality_of_research
            update_use_of_library_resources
            attach_or_update_files(requested_by)
          end
        end

        def attach_or_update_files(requested_by)
          repository.attach_files_to(work: work, files: files, predicate_name: 'faculty_comments_attachment')
          repository.remove_files_from(work: work, user: requested_by, pids: ids_for_deletion)
          repository.amend_files_metadata(work: work, user: requested_by, metadata: attachments_metadata)
        end

        def update_course
          repository.update_work_attribute_values!(work: work, key: 'course', values: course)
        end

        def update_nature_of_supervision
          repository.update_work_attribute_values!(work: work, key: 'nature_of_supervision', values: nature_of_supervision)
        end

        def update_supervising_semester
          repository.update_work_attribute_values!(work: work, key: 'supervising_semester', values: supervising_semester)
        end

        def update_quality_of_research
          repository.update_work_attribute_values!(work: work, key: 'quality_of_research', values: quality_of_research)
        end

        def update_use_of_library_resources
          repository.update_work_attribute_values!(work: work, key: 'use_of_library_resources', values: use_of_library_resources)
        end

        def retrieve_from_work(key:)
          repository.work_attribute_values_for(work: work, key: key)
        end

        def to_array_without_empty_values(value)
          Array.wrap(value).select(&:present?)
        end

        def attachments_metadata
          @attachments_metadata || {}
        end

        def ids_for_deletion
          @ids_for_deletion || []
        end

        def collect_files_for_deletion_and_update(value)
          @ids_for_deletion = []
          @attachments_metadata = {}
          value.each do |_key, attributes|
            if PowerConverter.convert_to_boolean(attributes['delete'])
              @ids_for_deletion << attributes.fetch('id')
            else
              @attachments_metadata[attributes.fetch('id')] = extract_permitted_attributes(attributes, 'name')
            end
          end
        end

        # Because strong parameters might be in play, I need to make sure to
        # permit these, or things fall apart later in the application.
        def extract_permitted_attributes(attributes, *keys)
          permitted_attributes = attributes.slice(*keys)
          permitted_attributes.permit! if permitted_attributes.respond_to?(:permit!)
          permitted_attributes
        end

        def attachments_from_work
          repository.work_attachments(work: work).map { |attachment| AttachmentFormElement.new(attachment) }
        end

        # Responsible for exposing a means of displaying and marking the object
        # for deletion.
        class AttachmentFormElement
          def initialize(attachment)
            self.attachment = attachment
          end
          delegate :id, :name, :thumbnail_url, :persisted?, :file_url, to: :attachment
          attr_accessor :delete

          private

          attr_accessor :attachment
        end
        private_constant :AttachmentFormElement
      end
    end
  end
end
