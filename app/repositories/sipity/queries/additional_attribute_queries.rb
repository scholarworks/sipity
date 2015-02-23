module Sipity
  module Queries
    # Queries
    module AdditionalAttributeQueries
      def work_attribute_values_for(work:, key:)
        Models::AdditionalAttribute.where(work: work, key: key).pluck(:value)
      end
      module_function :work_attribute_values_for
      public :work_attribute_values_for

      def work_attribute_key_value_pairs(work:, keys: [])
        query = Models::AdditionalAttribute.where(work: work).order(:work_id, :key)
        query = query.where(key: keys) if keys.present?
        query.pluck(:key, :value)
      end
      module_function :work_attribute_key_value_pairs
      public :work_attribute_key_value_pairs

      def work_attribute_keys_for(work:)
        Models::AdditionalAttribute.where(work: work).order(:key).pluck(:key).uniq
      end
      module_function :work_attribute_keys_for
      public :work_attribute_keys_for

      def work_default_attribute_keys_for(*)
        [:publication_date]
      end
      module_function :work_default_attribute_keys_for
      public :work_default_attribute_keys_for
    end
  end
end
