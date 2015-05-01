module Sipity
  module Forms
    module ComposableElements
      # Responsible for file attachments
      class AttachmentsExtension
        def initialize(form:, repository:, **args)
          self.form = form
          self.repository = repository
          self.files = args[:files] || {}
          self.attachments_attributes = args[:attachments_attributes] || {}
        end

        attr_accessor :form, :repository, :files
        attr_reader :attachments_attributes
        private(:form=, :repository=, :files=)

        delegate :action, :work, to: :form

        def attachments
          @attachments ||= attachments_from_work
        end

        def attachments_attributes=(value)
          @attachments_attributes = value
          collect_files_for_deletion_and_update
        end

        def attach_or_update_files(requested_by:, predicate_name: 'attachment')
          repository.attach_files_to(work: work, files: files, predicate_name: predicate_name) if files.any?
          repository.remove_files_from(work: work, user: requested_by, pids: ids_for_deletion)
          repository.amend_files_metadata(work: work, user: requested_by, metadata: attachments_metadata)
        end

        # Exposed so that it can be used
        # for validations outside of this class
        def attachments_metadata
          @attachments_metadata || {}
        end

        private

        def ids_for_deletion
          collect_files_for_deletion_and_update
          @ids_for_deletion || []
        end

        def collect_files_for_deletion_and_update
          @ids_for_deletion = []
          @attachments_metadata = {}
          attachments_attributes.each do |_key, attributes|
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
