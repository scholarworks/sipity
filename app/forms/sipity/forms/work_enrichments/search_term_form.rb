module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for search term
      class SearchTermForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.subject = attributes.fetch(:subject) { subject_from_work }
          self.language = attributes.fetch(:language) { language_from_work }
          self.temporal_coverage = attributes.fetch(:temporal_coverage) { temporal_coverage_from_work }
          self.spatial_coverage = attributes.fetch(:spatial_coverage) { spatial_coverage_from_work }
        end

        attr_accessor :subject, :language, :temporal_coverage, :spatial_coverage
        private(:subject=, :language=, :temporal_coverage=, :spatial_coverage=)

        private

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'subject', values: subject)
            repository.update_work_attribute_values!(work: work, key: 'language', values: language)
            repository.update_work_attribute_values!(work: work, key: 'temporal_coverage', values: temporal_coverage)
            repository.update_work_attribute_values!(work: work, key: 'spatial_coverage', values: spatial_coverage)
          end
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
