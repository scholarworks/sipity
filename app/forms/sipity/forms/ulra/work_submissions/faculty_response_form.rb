module Sipity
  module Forms
    module Ulra
      module WorkSubmissions
        # Responsible for capturing and validating information for faculty comments
        class FacultyResponseForm < Forms::WorkEnrichmentForm
          def initialize(attributes = {})
            super
            initialize_non_attachment_attributes(attributes)
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          attr_accessor :course, :nature_of_supervision, :quality_of_research, :use_of_library_resources, :attachments_extension
          attr_reader :supervising_semester

          delegate(
            :attachments,
            :attach_or_update_files,
            :attachments_attributes=,
            :files,
            to: :attachments_extension
          )

          private(
            :course=,
            :nature_of_supervision=,
            :quality_of_research=,
            :use_of_library_resources=,
            :attachments_extension,
            :attachments_extension=,
            :attach_or_update_files
          )

          validates :course, presence: true
          validates :nature_of_supervision, presence: true
          validates :quality_of_research, presence: true
          validates :use_of_library_resources, presence: true

          include Hydra::Validations
          validates :supervising_semester, presence: true

          private

          def initialize_non_attachment_attributes(attributes)
            self.course = attributes.fetch(:course) { retrieve_from_work(key: 'course') }
            self.nature_of_supervision = attributes.fetch(:nature_of_supervision) { retrieve_from_work(key: 'nature_of_supervision') }
            self.supervising_semester = attributes.fetch(:supervising_semester) { retrieve_from_work(key: 'supervising_semester') }
            self.quality_of_research = attributes.fetch(:quality_of_research) { retrieve_from_work(key: 'quality_of_research') }
            self.use_of_library_resources = attributes.fetch(:use_of_library_resources) do
              retrieve_from_work(key: 'use_of_library_resources')
            end
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
              attach_or_update_files(requested_by: requested_by, predicate_name: "faculty_comments_attachment")
            end
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

          def build_attachments(attachment_attr)
            ComposableElements::AttachmentsExtension.new(
              form: self,
              repository: repository,
              files: attachment_attr[:files],
              attachments_attributes: attachment_attr[:attachments_attributes]
            )
          end
        end
      end
    end
  end
end
