module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for degree.
      class DegreeForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          @degree = attributes.fetch(:degree) { degree_from_work }
        end

        attr_accessor :degree

        validates :degree, presence: true

        def degree_names
          repository.get_values_by_predicate_name(name: 'degree')
        end

        private

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'degree', values: degree)
          end
        end

        def degree_from_work
          repository.work_attribute_values_for(work: work, key: 'degree')
        end
      end
    end
  end
end
