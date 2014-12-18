module Sipity
  module Queries
    # Queries
    module AdditionalAttributeQueries
      def header_attribute_values_for(header:, key:)
        Models::AdditionalAttribute.where(header: header, key: key).pluck(:value)
      end
      module_function :header_attribute_values_for
      public :header_attribute_values_for

      def header_attribute_key_value_pairs(header:, keys: [])
        query = Models::AdditionalAttribute.where(header: header).order(:header_id, :key)
        query = query.where(key: keys) if keys.present?
        query.pluck(:key, :value)
      end
      module_function :header_attribute_key_value_pairs
      public :header_attribute_key_value_pairs

      def header_attribute_keys_for(header:)
        Models::AdditionalAttribute.where(header: header).order(:key).pluck('DISTINCT key')
      end
      module_function :header_attribute_keys_for
      public :header_attribute_keys_for

      def header_default_attribute_keys_for(*)
        [:publication_date]
      end
      module_function :header_default_attribute_keys_for
      public :header_default_attribute_keys_for
    end
  end
end
