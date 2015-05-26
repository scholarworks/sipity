module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing and validating information for search term
        class SearchTermForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:subject, :language, :temporal_coverage, :spatial_coverage]
          )

          def initialize(work:, attributes: {}, **keywords)
            self.work = work
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.subject = attributes.fetch(:subject) { subject_from_work }
            self.language = attributes.fetch(:language) { language_from_work }
            self.temporal_coverage = attributes.fetch(:temporal_coverage) { temporal_coverage_from_work }
            self.spatial_coverage = attributes.fetch(:spatial_coverage) { spatial_coverage_from_work }
          end

          def submit(requested_by:)
            processing_action_form.submit(requested_by: requested_by) do
              repository.update_work_attribute_values!(work: work, key: 'subject', values: subject)
              repository.update_work_attribute_values!(work: work, key: 'language', values: language)
              repository.update_work_attribute_values!(work: work, key: 'temporal_coverage', values: temporal_coverage)
              repository.update_work_attribute_values!(work: work, key: 'spatial_coverage', values: spatial_coverage)
            end
          end

          include ActiveModel::Validations

          private

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
