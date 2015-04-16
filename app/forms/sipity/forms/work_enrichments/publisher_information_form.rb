module Sipity
  module Forms
    module WorkEnrichments
      # Responsible for capturing and validating information for publisher information
      class PublisherInformationForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.publication_name = attributes.fetch(:publication_name) { publication_name_from_work }
          self.allow_pre_prints = attributes.fetch(:allow_pre_prints) { allow_pre_prints_from_work }
        end

        attr_accessor :publication_name
        attr_reader :allow_pre_prints

        include ActiveModel::Validations
        include Hydra::Validations
        validates :publication_name, presence: true

        VALID_VALUES_FOR_ALLOW_PRE_PRINTS = ["Yes", "No", "I do not know"].freeze
        validates :allow_pre_prints, inclusion: { in: VALID_VALUES_FOR_ALLOW_PRE_PRINTS }

        private

        def allow_pre_prints=(values)
          @allow_pre_prints = to_array_without_empty_values(values)
        end

        def save(requested_by:)
          super do
            repository.update_work_attribute_values!(work: work, key: 'publication_name', values: publication_name)
            repository.update_work_attribute_values!(work: work, key: 'allow_pre_prints', values: allow_pre_prints)
          end
        end

        def publication_name_from_work
          repository.work_attribute_values_for(work: work, key: 'publication_name')
        end

        def allow_pre_prints_from_work
          repository.work_attribute_values_for(work: work, key: 'allow_pre_prints')
        end

        def to_array_without_empty_values(value)
          Array.wrap(value).select(&:present?)
        end
      end
    end
  end
end
