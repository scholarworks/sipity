module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for research process
        class ResearchProcessForm < Forms::WorkEnrichmentForm
          def initialize(attributes = {})
            super
            initialize_non_attachment_attributes(attributes)
            self.attachments_extension = build_attachments(attributes.slice(:files, :attachments_attributes))
          end

          attr_reader :resource_consulted
          attr_accessor :citation_style, :other_resource_consulted, :attachments_extension

          delegate(
            :attachments,
            :attach_or_update_files,
            :attachments_attributes=,
            :files,
            to: :attachments_extension
          )

          private(:citation_style=, :other_resource_consulted=, :attachments_extension, :attachments_extension=, :attach_or_update_files)

          validates :citation_style, presence: true

          def available_resource_consulted
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'resource_consulted')
          end

          def available_citation_style
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'citation_style')
          end

          private

          def initialize_non_attachment_attributes(attributes)
            self.resource_consulted = attributes.fetch(:resource_consulted) { retrieve_from_work(key: 'resource_consulted') }
            self.other_resource_consulted = attributes.fetch(:other_resource_consulted) do
              retrieve_from_work(key: 'other_resource_consulted')
            end
            self.citation_style = attributes.fetch(:citation_style) { retrieve_from_work(key: 'citation_style') }
          end

          def save(requested_by:)
            super do
              repository.update_work_attribute_values!(work: work, key: 'resource_consulted', values: resource_consulted)
              repository.update_work_attribute_values!(work: work, key: 'other_resource_consulted', values: other_resource_consulted)
              repository.update_work_attribute_values!(work: work, key: 'citation_style', values: citation_style)
              attach_or_update_files(requested_by: requested_by, predicate_name: "research_process_attachment")
            end
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

          def build_attachments(attachment_attr)
            ComposableElements::AttachmentsExtension.new(
              form: self,
              repository: repository,
              files: attachment_attr[:files],
              attachments_attributes: attachment_attr[:attachments_attributes]
            )
          end
        end
      end
    end
  end
end
