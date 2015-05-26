module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing and validating information for degree.
        class DegreeForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:degree, :program_name]
          )

          def initialize(work:, attributes: {}, **keywords)
            self.work = work
            self.processing_action_form = ProcessingForm.new(form: self, **keywords)
            self.degree = attributes.fetch(:degree) { degree_from_work }
            self.program_name = attributes.fetch(:program_name) { program_name_from_work }
          end

          include ActiveModel::Validations
          validates :degree, presence: true
          validates :program_name, presence: true

          def available_degrees
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'degree')
          end

          def available_program_names
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'program_name')
          end

          private

          def degree=(values)
            @degree = to_array_without_empty_values(values)
          end

          def program_name=(values)
            @program_name = to_array_without_empty_values(values)
          end

          def save(*)
            repository.update_work_attribute_values!(work: work, key: 'degree', values: degree)
            repository.update_work_attribute_values!(work: work, key: 'program_name', values: program_name)
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
end
