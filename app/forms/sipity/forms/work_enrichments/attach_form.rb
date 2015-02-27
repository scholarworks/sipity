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
          Queries::AttachmentQueries.representative_attachment_for(work: work)
        end

        def attachments
          @attachments ||= attachments_from_work
        end

        # Exposed so that field_for will work
        def attachments_attributes=(_value)
        end

        private

        def save(repository:, requested_by:)
          super do
            Array.wrap(files).compact.each do |file|
              repository.attach_file_to(work: work, file: file, user: requested_by)
            end
            repository.mark_as_representative(work: work, pid: mark_as_representative, user: requested_by)
          end
        end

        def attachments_from_work
          return [] unless work
          # I don't want this to be draped because the collection appeared to be
          # treated as a single model instead of as an enumeration of items.
          work.attachments.map { |attachment| AttachmentFormElement.new(attachment) }
        end
      end

      # Responsible for exposing a means of displaying and marking the object
      # for deletion.
      class AttachmentFormElement
        THUMBNAIL_SIZE = '64x64#'
        def initialize(object)
          @object = object
        end

        def thumbnail_url(size = THUMBNAIL_SIZE)
          thumbnail(size).url
        end

        delegate :id, :name, :persisted?, to: :object
        attr_accessor :delete

        private

        attr_reader :object
        private :object

        def thumbnail(size = THUMBNAIL_SIZE)
          object.file.thumb(size, format: 'png', frame: 0)
        end
      end
    end
  end
end
