module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for research process
      class ResearchProcessForm < Forms::WorkEnrichmentForm
        include Conversions::SanitizeHtml
        def initialize(attributes = {})
          super
          self.resource_consulted = attributes.fetch(:resource_consulted) { resource_consulted_from_work }
          self.other_resource_consulted = attributes.fetch(:other_resource_consulted) { other_resource_consulted_from_work }
          self.citation_style = attributes.fetch(:citation_style) { citation_style_from_work }
        end

        attr_reader :resource_consulted
        attr_accessor :citation_style, :other_resource_consulted

        validates :citation_style, presence: true

        def available_resource_consulted
          repository.get_controlled_vocabulary_values_for_predicate_name(name: 'resource_consulted')
        end

        def available_citation_style
          repository.get_controlled_vocabulary_values_for_predicate_name(name: 'citation_style')
        end

        private

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'resource_consulted', values: resource_consulted)
            repository.update_work_attribute_values!(work: work, key: 'other_resource_consulted', values: other_resource_consulted)
            repository.update_work_attribute_values!(work: work, key: 'citation_style', values: citation_style)
          end
        end

        def resource_consulted=(values)
          @resource_consulted = to_array_without_empty_values(values)
        end

        def resource_consulted_from_work
          repository.work_attribute_values_for(work: work, key: 'resource_consulted')
        end

        def other_resource_consulted_from_work
          repository.work_attribute_values_for(work: work, key: 'other_resource_consulted')
        end

        def citation_style_from_work
          repository.work_attribute_values_for(work: work, key: 'citation_style')
        end

        def to_array_without_empty_values(value)
          Array.wrap(value).select(&:present?)
        end
      end
    end
  end
end
