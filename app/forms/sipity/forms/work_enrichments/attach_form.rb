module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.files = attributes[:files]
          self.representative_attachment_id = attributes.fetch(:representative_attachment_id) { representative_attachment_id_from_work }
          self.attachments_attributes = attributes.fetch(:attachments_attributes, {})
        end

        attr_accessor :files, :representative_attachment_id
        private(:files=, :representative_attachment_id=)
        validate :at_least_one_file_must_be_attached

        def attachments
          @attachments ||= attachments_from_work
        end

        # Exposed so that field_for will work
        def attachments_attributes=(value)
          @attachments_attributes = value
          collect_files_for_deletion_and_update(value)
        end

        private

        def representative_attachment_id_from_work
          repository.representative_attachment_for(work: work).to_param
        end

        def save(requested_by:)
          super do
            repository.attach_files_to(work: work, files: files, user: requested_by)
            repository.set_as_representative_attachment(work: work, pid: representative_attachment_id)
            repository.remove_files_from(work: work, user: requested_by, pids: ids_for_deletion)
            repository.amend_files_metadata(work: work, user: requested_by, metadata: attachments_metadata)
            # HACK: This is expanding the knowledge of what action is being
            #   taken. Instead it is something that should be modeled in the
            #   underlying database. That is to say: When an action fires what
            #   actions should be registered and what actions should be
            #   unregistered.
            repository.unregister_action_taken_on_entity(work: work, enrichment_type: 'access_policy', requested_by: requested_by)
          end
        end

        def attachments_metadata
          @attachments_metadata || {}
        end

        def ids_for_deletion
          @ids_for_deletion || []
        end

        include Conversions::ConvertToBoolean

        def collect_files_for_deletion_and_update(value)
          @ids_for_deletion = []
          @attachments_metadata = {}
          value.each do |_key, attributes|
            if convert_to_boolean(attributes['delete'])
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

        def attachments_associated_with_the_work?
          attachments_metadata.present? || files.present?
        end

        def at_least_one_file_must_be_attached
          return true if attachments_associated_with_the_work?
          errors.add(:base, :at_least_one_attachment_required)
        end

        # Responsible for exposing a means of displaying and marking the object
        # for deletion.
        class AttachmentFormElement
          def initialize(attachment)
            @attachment = attachment
          end
          delegate :id, :name, :thumbnail_url, :persisted?, :file_url, to: :attachment
          attr_accessor :delete
          attr_reader :attachment
          private :attachment
        end
        private_constant :AttachmentFormElement
      end
    end
  end
end
