require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for faculty comments
        class FacultyResponseForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:course, :nature_of_supervision, :supervising_semester, :quality_of_research, :use_of_library_resources]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_non_attachment_attributes(attributes)
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          def available_supervising_semester
            Array.wrap(repository.available_supervising_semester_for(work: work))
          end
          alias_method :supervising_semester_for_select, :available_supervising_semester

          private

          attr_accessor :attachments_extension

          public

          delegate(
            :attachments, :attach_or_update_files, :attachments_attributes=, :files,
            to: :attachments_extension
          )
          private(:attach_or_update_files)

          include ActiveModel::Validations
          include Hydra::Validations
          validates :course, presence: true
          validates :nature_of_supervision, presence: true
          validates :quality_of_research, presence: true
          validates :use_of_library_resources, presence: true
          validates :supervising_semester, presence: true, inclusion: { in: :available_supervising_semester }

          def submit
            processing_action_form.submit do
              update_course
              update_nature_of_supervision
              update_supervising_semester
              update_quality_of_research
              update_use_of_library_resources
              attach_or_update_files(requested_by: requested_by, predicate_name: "faculty_comments_attachment")
            end
          end

          private

          def initialize_non_attachment_attributes(attributes)
            self.course = retrieve(key: :course, from: attributes, cardinality: 1)
            self.nature_of_supervision = retrieve(key: :nature_of_supervision, from: attributes, cardinality: 1)
            self.supervising_semester = retrieve(key: :supervising_semester, from: attributes, cardinality: :many)
            self.quality_of_research = retrieve(key: :quality_of_research, from: attributes, cardinality: 1)
            self.use_of_library_resources = retrieve(key: :use_of_library_resources, from: attributes, cardinality: 1)
          end

          def retrieve(key:, from:, cardinality: 1)
            from.fetch(key) { repository.work_attribute_values_for(work: work, key: key.to_s, cardinality: cardinality) }
          end

          def supervising_semester=(values)
            @supervising_semester = to_array_without_empty_values(values)
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
