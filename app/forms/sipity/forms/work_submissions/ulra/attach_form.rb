require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Exposes a means for attaching files to the associated work.
        class AttachForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:files, :attachments_attributes, :representative_attachment_id, :attached_files_completion_state]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.representative_attachment_id = attributes.fetch(:representative_attachment_id) { representative_attachment_id_from_work }
            self.attached_files_completion_state = attributes.fetch(:attached_files_completion_state) do
              attached_files_completion_state_from_work
            end
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          private

          attr_accessor :attachments_extension

          public

          include ActiveModel::Validations
          validate :at_least_one_file_must_be_attached
          validates :work, presence: true
          validates :requested_by, presence: true
          validates(
            :attached_files_completion_state,
            presence: true,
            inclusion: { in: ->(record) { record.possible_attached_files_completion_states } }
          )

          def possible_attached_files_completion_states
            ['incomplete', 'complete']
          end

          delegate(
            :attachments,
            :attachments_metadata,
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
            repository.update_work_attribute_values!(
              work: work, key: 'attached_files_completion_state', values: attached_files_completion_state
            )
            # HACK: This is expanding the knowledge of what action is being
            #   taken. Instead it is something that should be modeled in the
            #   underlying database. That is to say: When an action fires what
            #   actions should be registered and what actions should be
            #   unregistered.
            repository.unregister_action_taken_on_entity(entity: work, action: 'access_policy', requested_by: requested_by)
          end

          def representative_attachment_id_from_work
            repository.representative_attachment_for(work: work).to_param
          end

          def attached_files_completion_state_from_work
            repository.work_attribute_values_for(work: work, key: 'attached_files_completion_state', cardinality: 1)
          end

          def attachments_associated_with_the_work?
            attachments_metadata.present? || files.present?
          end

          def at_least_one_file_must_be_attached
            return true if attachments_associated_with_the_work?
            errors.add(:base, :at_least_one_attachment_required)
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
