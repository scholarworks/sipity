module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.representative_attachment_id = attributes.fetch(:representative_attachment_id) { representative_attachment_id_from_work }
          self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
        end

        attr_accessor :representative_attachment_id, :attachments_extension
        validate :at_least_one_file_must_be_attached

        delegate(
          :attachments,
          :attachments_metadata,
          :attach_or_update_files,
          :attachments_attributes=,
          :files,
          to: :attachments_extension
        )
        private(:representative_attachment_id=, :attachments_extension, :attachments_extension=, :attach_or_update_files)

        private

        def representative_attachment_id_from_work
          repository.representative_attachment_for(work: work).to_param
        end

        def save(requested_by:)
          super do
            repository.set_as_representative_attachment(work: work, pid: representative_attachment_id)
            attach_or_update_files(requested_by: requested_by)
            # HACK: This is expanding the knowledge of what action is being
            #   taken. Instead it is something that should be modeled in the
            #   underlying database. That is to say: When an action fires what
            #   actions should be registered and what actions should be
            #   unregistered.
            repository.unregister_action_taken_on_entity(work: work, enrichment_type: 'access_policy', requested_by: requested_by)
          end
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
