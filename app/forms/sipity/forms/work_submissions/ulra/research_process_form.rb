require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for research process
        class ResearchProcessForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:resources_consulted, :other_resources_consulted]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_non_attachment_attributes(attributes)
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          private

          attr_accessor :attachments_extension

          public

          delegate(
            :attachments, :attach_or_update_files, :attachments_attributes=, :files, :attachment_predicate_name,
            :at_least_one_file_must_be_attached, to: :attachments_extension
          )

          private(:attach_or_update_files)

          include ActiveModel::Validations
          validate :at_least_one_file_must_be_attached

          def available_resources_consulted
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'resources_consulted')
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'resources_consulted', values: resources_consulted)
              repository.update_work_attribute_values!(work: work, key: 'other_resources_consulted', values: other_resources_consulted)
              attach_or_update_files(requested_by: requested_by)
            end
          end

          private

          def initialize_non_attachment_attributes(attributes)
            self.resources_consulted = attributes.fetch(:resources_consulted) { retrieve_from_work(key: 'resources_consulted') }
            self.other_resources_consulted = attributes.fetch(:other_resources_consulted) do
              retrieve_from_work(key: 'other_resources_consulted').first
            end
          end

          def resources_consulted=(values)
            @resources_consulted = to_array_without_empty_values(values)
          end

          def retrieve_from_work(key:)
            Array.wrap(repository.work_attribute_values_for(work: work, key: key))
          end

          def to_array_without_empty_values(value)
            Array.wrap(value).select(&:present?)
          end

          def build_attachments(attachment_attr)
            ComposableElements::AttachmentsExtension.new(
              form: self,
              repository: repository,
              files: attachment_attr[:files],
              predicate_name: 'application_essay',
              attachments_attributes: attachment_attr[:attachments_attributes]
            )
          end
        end
      end
    end
  end
end
