require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module SelfDeposit
        # Responsible for capturing and validating information for search term
        class SearchTermForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:subject, :language, :temporal_coverage, :spatial_coverage]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_attributes(attributes)
          end

          def submit
            processing_action_form.submit do
              update_attribute_values('subject')
              update_attribute_values('language')
              update_attribute_values('temporal_coverage')
              update_attribute_values('spatial_coverage')
            end
          end

          include ActiveModel::Validations

          private

          def initialize_attributes(attributes)
            self.subject = attributes.fetch(:subject) { subject_from_work }
            self.language = attributes.fetch(:language) { language_from_work }
            self.temporal_coverage = attributes.fetch(:temporal_coverage) { temporal_coverage_from_work }
            self.spatial_coverage = attributes.fetch(:spatial_coverage) { spatial_coverage_from_work }
          end

          def update_attribute_values(key)
            repository.update_work_attribute_values!(work: work, key: key, values: send(key))
          end

          def subject_from_work
            repository.work_attribute_values_for(work: work, key: 'subject')
          end

          def language_from_work
            repository.work_attribute_values_for(work: work, key: 'language')
          end

          def temporal_coverage_from_work
            repository.work_attribute_values_for(work: work, key: 'temporal_coverage')
          end

          def spatial_coverage_from_work
            repository.work_attribute_values_for(work: work, key: 'spatial_coverage')
          end
        end
      end
    end
  end
end
