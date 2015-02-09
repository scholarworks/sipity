module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class AttachForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @files = attributes[:files]
          @mark_as_representative = attributes[:mark_as_representative]
          @attachments_attributes = attributes[:attachments_attributes]
        end

        # TODO: Write a custom file validator. There must be at least one file
        #   uploaded.
        validates :files, presence: true
        attr_accessor :files
        attr_accessor :mark_as_representative
        attr_reader :attachments_attributes

        def attachments_attributes(inputs)
          return inputs unless inputs.present?
          @attachments = []
          inputs.each do |_, attributes|
            build_attachment_from_input(@attachments, attributes)
          end
          @attachments_attributes = inputs
        end

        def representative
          Queries::AttachmentQueries.work_representative(work: work)
        end

        def attachments
          @attachments || attachments_from_work
        end

        private

        def build_attachment_from_input(collection, attributes)
          return unless attributes[:pid].present?
          attachment = Queries::AttachmentQueries.find_or_initialize_attachments_by(work: work, pid: attributes[:pid])
          attachment.attributes = extract_attachment_attributes(attributes)
          collection << attachment
        end

        def extract_attachment_attributes(attributes)
          permitted_attributes = attributes.slice(:pid, :name, :mark_as_representative)
          # Because Rails strong parameters may or may not be in play.
          permitted_attributes.permit! if permitted_attributes.respond_to?(:permit!)
          permitted_attributes
        end

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
