require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'sipity/forms'
module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        # Capture completion requirements for this project
        class CompletionRequirementForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:project_must_complete_by_date, :project_must_complete_by_reason]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_attributes(attributes)
          end

          public

          include ActiveModel::Validations
          validates :project_must_complete_by_date, presence: true
          validates :project_must_complete_by_reason, presence: true

          def submit
            processing_action_form.submit do
              ['project_must_complete_by_date', 'project_must_complete_by_reason'].each do |predicate_name|
                repository.update_work_attribute_values!(work: work, key: predicate_name, values: send(predicate_name))
              end
            end
          end

          private

          include Conversions::ExtractInputDateFromInput
          def initialize_attributes(attributes)
            self.project_must_complete_by_reason = attributes.fetch(:project_must_complete_by_reason) do
              repository.work_attribute_values_for(work: work, key: 'project_must_complete_by_reason', cardinality: 1)
            end

            self.project_must_complete_by_date = extract_input_date_from_input(:project_must_complete_by_date, attributes) do
              repository.work_attribute_values_for(work: work, key: 'project_must_complete_by_date', cardinality: 1)
            end
          end

          include Conversions::ConvertToDate
          def project_must_complete_by_date=(input)
            @project_must_complete_by_date = convert_to_date(input) { nil }
          end
        end
      end
    end
  end
end
