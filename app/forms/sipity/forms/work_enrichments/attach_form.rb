module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @files = attributes[:files]
        end

        # TODO: Write a custom file validator. There must be at least one file
        #   uploaded.
        validates :files, presence: true
        attr_accessor :files

        private

        def save(repository:, requested_by:)
          super do
            Array.wrap(files).compact.each do |file|
              repository.attach_file_to(work: work, file: file, user: requested_by)
            end
          end
        end
      end
    end
  end
end
