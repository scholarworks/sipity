require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for plan_of_study.
        class PlanOfStudyForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:expected_graduation_date, :majors]
          )

          include Conversions::ExtractInputDateFromInput
          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.expected_graduation_date = extract_input_date_from_input(:expected_graduation_date, attributes) do
              expected_graduation_date_from_work
            end
            self.majors = attributes.fetch(:majors) { majors_from_work }
          end

          include ActiveModel::Validations
          include Hydra::Validations
          validates :expected_graduation_date, presence: true
          validates :majors, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'expected_graduation_date', values: expected_graduation_date)
              repository.update_work_attribute_values!(work: work, key: 'majors', values: majors)
            end
          end

          private

          def expected_graduation_date_from_work
            repository.work_attribute_values_for(work: work, key: 'expected_graduation_date')
          end

          def majors_from_work
            repository.work_attribute_values_for(work: work, key: 'majors')
          end

          def majors=(values)
            @majors = to_array_without_empty_values(values)
          end

          include Conversions::ConvertToDate
          def expected_graduation_date=(value)
            @expected_graduation_date = convert_to_date(value) { nil }
          end

          def to_array_without_empty_values(value)
            Array.wrap(value).select(&:present?)
          end
        end
      end
    end
  end
end
