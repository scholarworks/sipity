module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @files = attributes[:files]
          @mark_as_representative = attributes[:mark_as_representative]
          self.attachments_attributes = attributes.fetch(:attachments_attributes, {})
        end

        attr_accessor :files
        attr_accessor :mark_as_representative

        def representative_attachment
          repository.representative_attachment_for(work: work)
        end

        def attachments
          @attachments ||= attachments_from_work
        end

        # Exposed so that field_for will work
        def attachments_attributes=(value)
          @attachments_attributes = value
          collect_files_for_deletion(value)
        end

        private

        def save(requested_by:)
          super do
            Array.wrap(files).compact.each do |file|
              repository.attach_file_to(work: work, file: file, user: requested_by)
            end
            repository.mark_as_representative(work: work, pid: mark_as_representative, user: requested_by)
            repository.remove_files_from(work: work, user: requested_by, pids: ids_for_deletion)
          end
        end

        def ids_for_deletion
          @ids_for_deletion || []
        end

        include Conversions::ConvertToBoolean

        def collect_files_for_deletion(value)
          @ids_for_deletion = []
          value.each do |_key, attributes|
            next unless convert_to_boolean(attributes['delete'])
            @ids_for_deletion << attributes.fetch('id')
          end
        end

        def attachments_from_work
          return [] unless work
          # I don't want this to be draped because the collection appeared to be
          # treated as a single model instead of as an enumeration of items.
          work.attachments.map { |attachment| AttachmentFormElement.new(attachment) }
        end

        # Responsible for exposing a means of displaying and marking the object
        # for deletion.
        class AttachmentFormElement
          def initialize(attachment)
            @attachment = attachment
          end
          delegate :id, :name, :thumbnail_url, :persisted?, to: :attachment
          attr_accessor :delete
          attr_reader :attachment
          private :attachment
        end
        private_constant :AttachmentFormElement
      end
    end
  end
end
