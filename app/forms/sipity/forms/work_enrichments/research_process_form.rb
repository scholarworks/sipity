module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for research process
      class ResearchProcessForm < Forms::WorkEnrichmentForm
        include Conversions::SanitizeHtml
        def initialize(attributes = {})
          super
          self.files = attributes[:files]
          self.resource_consulted = attributes.fetch(:resource_consulted) { retrieve_from_work(key: 'resource_consulted') }
          self.other_resource_consulted = attributes.fetch(:other_resource_consulted) do
            retrieve_from_work(key: 'other_resource_consulted')
          end
          self.citation_style = attributes.fetch(:citation_style) { retrieve_from_work(key: 'citation_style') }
          self.attachments_attributes = attributes.fetch(:attachments_attributes, {})
        end

        attr_reader :resource_consulted
        attr_accessor :files, :citation_style, :other_resource_consulted
        private(:files=, :citation_style=, :other_resource_consulted=)

        validates :citation_style, presence: true

        def available_resource_consulted
          repository.get_controlled_vocabulary_values_for_predicate_name(name: 'resource_consulted')
        end

        def available_citation_style
          repository.get_controlled_vocabulary_values_for_predicate_name(name: 'citation_style')
        end

        def attachments
          @attachments ||= attachments_from_work
        end

        # Exposed so that field_for will work
        def attachments_attributes=(value)
          collect_files_for_deletion_and_update(value)
        end

        private

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'resource_consulted', values: resource_consulted)
            repository.update_work_attribute_values!(work: work, key: 'other_resource_consulted', values: other_resource_consulted)
            repository.update_work_attribute_values!(work: work, key: 'citation_style', values: citation_style)
            attach_or_update_files(requested_by)
          end
        end

        def attach_or_update_files(requested_by)
          repository.attach_files_to(work: work, files: files, predicate_name: 'research_process_attachment')
          repository.remove_files_from(work: work, user: requested_by, pids: ids_for_deletion)
          repository.amend_files_metadata(work: work, user: requested_by, metadata: attachments_metadata)
        end

        def resource_consulted=(values)
          @resource_consulted = to_array_without_empty_values(values)
        end

        def retrieve_from_work(key:)
          repository.work_attribute_values_for(work: work, key: key)
        end

        def to_array_without_empty_values(value)
          Array.wrap(value).select(&:present?)
        end

        def attachments_metadata
          @attachments_metadata || {}
        end

        def ids_for_deletion
          @ids_for_deletion || []
        end

        def collect_files_for_deletion_and_update(value)
          @ids_for_deletion = []
          @attachments_metadata = {}
          value.each do |_key, attributes|
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
