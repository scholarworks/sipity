module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @files = attributes[:files]
          @mark_as_representative = attributes[:mark_as_representative]
        end

        # TODO: Write a custom file validator. There must be at least one file
        #   uploaded.
        validates :files, presence: true
        attr_accessor :files
        attr_accessor :mark_as_representative

        def representative_attachment
          Queries::AttachmentQueries.representative_attachment_for(work: work)
        end

        def attachments
          @attachments || attachments_from_work
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
          work.attachments
        end
      end
    end
  end
end
