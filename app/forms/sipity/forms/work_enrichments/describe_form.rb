module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for describe.
      class DescribeForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @abstract = attributes[:abstract]
        end

        attr_accessor :abstract

        validates :abstract, presence: true

        private

        def save(repository:, requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'abstract', values: abstract)
          end
        end
      end
    end
  end
end
