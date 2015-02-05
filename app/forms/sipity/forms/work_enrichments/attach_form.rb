module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @files = attributes[:files]
          @remove_files = attributes[:remove_files]
          @mark_as_representative = attributes[:mark_as_representative]
        end

        # TODO: Write a custom file validator. There must be at least one file
        #   uploaded.
        validates :files, presence: true
        attr_accessor :files
        attr_accessor :remove_files
        attr_accessor :mark_as_representative

        def attachments_from_work
          return [] unless work
          work.attachments.present? ? work.attachments.map(&:file_name) : []
        end

        def representative
          work.attachments.map(&:file_name)
        end

        def attachments(decorator: Decorators::AttachmentDecorator)
          Queries::AttachmentQueries.work_attachments(work: work).
            map { |obj| decorator.decorate(obj) }
        end

        private

        def save(repository:, requested_by:)
          super do
            Array.wrap(files).compact.each do |file|
              repository.attach_file_to(work: work, file: file, user: requested_by)
            end
            Array.wrap(remove_files).compact.each do |file_name|
              repository.remove_files_from(file_name: file_name, user: requested_by)
            end
            repository.mark_as_representative(file_name: mark_as_representative, user: requested_by)
          end
        end
      end
    end
  end
end
