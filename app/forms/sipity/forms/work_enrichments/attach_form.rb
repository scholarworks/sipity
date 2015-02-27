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
      end
    end
  end
end
