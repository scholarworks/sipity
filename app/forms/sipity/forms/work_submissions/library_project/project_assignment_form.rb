require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'sipity/forms'
module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        class ProjectAssignmentForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [
              :project_issue_type, :project_assigned_to_person
            ]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_attributes(attributes)
          end

          public

          include ActiveModel::Validations
          validates :project_assigned_to_person, presence: true
          validates :project_issue_type, presence: true, inclusion: { in: :project_issue_type_for_select }

          PROJECT_ISSUE_TYPE_FOR_SELECT = ['Enduring Commitment', 'Request', 'Special Project', 'Strategic Initiative'].freeze
          def project_issue_type_for_select
            PROJECT_ISSUE_TYPE_FOR_SELECT
          end

          def submit
            processing_action_form.submit do
              [
                'project_issue_type', 'project_assigned_to_person'
              ].each do |predicate_name|
                repository.update_work_attribute_values!(work: work, key: predicate_name, values: send(predicate_name))
              end
            end
          end

          private

          def initialize_attributes(attributes)
            [
              [:project_issue_type, 1], [:project_assigned_to_person, 1]
            ].each do |attribute_name, cardinality|
              value = attributes.fetch(attribute_name) do
                repository.work_attribute_values_for(work: work, key: attribute_name.to_s, cardinality: cardinality)
              end
              send("#{attribute_name}=", value)
            end
          end

          def default_repository
            CommandRepository.new
          end
        end
      end
    end
  end
end
