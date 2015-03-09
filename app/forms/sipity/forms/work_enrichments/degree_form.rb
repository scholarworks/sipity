module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for degree.
      class DegreeForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.degree = attributes.fetch(:degree) { degree_from_work }
          self.program_name = attributes.fetch(:program_name) { program_name_from_work }
        end

        attr_reader :degree, :program_name

        validates :degree, presence: true
        validates :program_name, presence: true

        def available_degrees
          repository.get_values_by_predicate_name(name: 'degree')
        end

        def available_program_names
          repository.get_values_by_predicate_name(name: 'program')
        end

        private

        def degree=(values)
          @degree = to_array_without_empty_values(values)
        end

        def program_name=(values)
          @program_name = to_array_without_empty_values(values)
        end

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'degree', values: degree)
            repository.update_work_attribute_values!(work: work, key: 'program_name', values: program_name)
          end
        end

        def degree_from_work
          repository.work_attribute_values_for(work: work, key: 'degree')
        end

        def program_name_from_work
          repository.work_attribute_values_for(work: work, key: 'program_name')
        end

        def to_array_without_empty_values(value)
          Array.wrap(value).select(&:present?)
        end
      end
    end
  end
end
