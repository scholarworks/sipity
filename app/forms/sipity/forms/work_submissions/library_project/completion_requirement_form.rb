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

          def initialize_attributes(attributes)
            [
              [:project_must_complete_by_date, 1], [:project_must_complete_by_reason, 1]
            ].each do |attribute_name, cardinality|
              value = attributes.fetch(attribute_name) do
                repository.work_attribute_values_for(work: work, key: attribute_name.to_s, cardinality: cardinality)
              end
              send("#{attribute_name}=", value)
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
