module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @files = attributes[:files]
          @remove_files = attributes[:remove_files]
        end

        # TODO: Write a custom file validator. There must be at least one file
        #   uploaded.
        validates :files, presence: true
        attr_accessor :files
        attr_accessor :remove_files

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
          end
        end
      end
    end
  end
end
