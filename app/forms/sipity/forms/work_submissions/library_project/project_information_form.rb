require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'sipity/forms'
module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        # Capture project related information to help make determinations
        class ProjectInformationForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [
              :title, :project_description, :project_impact, :whom_does_this_impact, :project_management_services_requested,
              :project_priority
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
          validates :title, presence: true
          validates :project_description, presence: true
          validates :project_impact, presence: true
          validates :whom_does_this_impact, presence: true
          validates :project_priority, presence: true, inclusion: { in: :project_priority_for_select }
          validates(
            :project_management_services_requested, presence: true, inclusion: { in: :project_management_services_requested_for_select }
          )

          PROJECT_MANAGEMENT_SERVICES_REQUESTED_FOR_SELECT = ['Yes', 'No', 'Maybe'].freeze
          def project_management_services_requested_for_select
            PROJECT_MANAGEMENT_SERVICES_REQUESTED_FOR_SELECT
          end

          PROJECT_PRIORITY_FOR_SELECT = ['Low', 'Medium', 'High', 'Critical'].freeze
          def project_priority_for_select
            PROJECT_PRIORITY_FOR_SELECT
          end

          def submit
            processing_action_form.submit do
              repository.update_work_title!(work: work, title: title)
              [
                'project_description', 'project_priority', 'project_impact', 'whom_does_this_impact',
                'project_management_services_requested'
              ].each do |predicate_name|
                repository.update_work_attribute_values!(work: work, key: predicate_name, values: send(predicate_name))
              end
            end
          end

          private

          def initialize_attributes(attributes)
            self.title = attributes.fetch(:title) { work.title }
            [
              [:project_description, 1], [:project_impact, 1], [:whom_does_this_impact, 1],
              [:project_management_services_requested, 1], [:project_priority, 1]
            ].each do |attribute_name, cardinality|
              value = attributes.fetch(attribute_name) do
                repository.work_attribute_values_for(work: work, key: attribute_name.to_s, cardinality: cardinality)
              end
              send("#{attribute_name}=", value)
            end
          end
        end
      end
    end
  end
end
