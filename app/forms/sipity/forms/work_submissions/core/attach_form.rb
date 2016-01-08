require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Exposes a means for attaching files to the associated work.
        class AttachForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:files, :attachments_attributes, :representative_attachment_id]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.representative_attachment_id = attributes.fetch(:representative_attachment_id) { representative_attachment_id_from_work }
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          private

          attr_accessor :attachments_extension

          public

          include ActiveModel::Validations
          validate :at_least_one_file_must_be_attached
          validates :work, presence: true
          validates :requested_by, presence: true

          delegate(
            :attachments, :attachments_associated_with_the_work?,
            :attachments_metadata, :at_least_one_file_must_be_attached,
            :attach_or_update_files,
            :attachments_attributes=,
            :files,
            to: :attachments_extension
          )
          private(:attach_or_update_files)

          def submit
            processing_action_form.submit { save }
          end

          private

          def save
            repository.set_as_representative_attachment(work: work, pid: representative_attachment_id)
            attach_or_update_files(requested_by: requested_by)
          end

          def representative_attachment_id_from_work
            repository.representative_attachment_for(work: work).to_param
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
