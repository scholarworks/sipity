require 'active_support/core_ext/array/wrap'

module Sipity
  # :nodoc:
  module Commands
    # Commands
    module AdditionalAttributeCommands
      def update_work_attribute_values!(work:, key:, values:, repository: self)
        input_values = Array.wrap(values)
        existing_values = repository.work_attribute_values_for(work: work, key: key)
        create_work_attribute_values!(work: work, key: key, values: (input_values - existing_values))
        destroy_work_attribute_values!(work: work, key: key, values: (existing_values - input_values))
      end

      def create_work_attribute_values!(work:, key:, values:)
        scrubber = Models::AdditionalAttribute.scrubber_for(predicate_name: key)
        Array.wrap(values).each do |raw_value|
          value = scrubber.sanitize(raw_value)
          Models::AdditionalAttribute.create!(work: work, key: key, value: value) if value.present?
        end
      end

      def destroy_work_attribute_values!(work:, key:, values:)
        values_to_destroy = Array.wrap(values)
        return true unless values_to_destroy.present?
        Models::AdditionalAttribute.where(work: work, key: key, value: values_to_destroy).destroy_all
      end
    end
  end
end
