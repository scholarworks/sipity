module Sipity
  module Queries
    # Queries
    module AdditionalAttributeQueries
      def sip_attribute_values_for(sip:, key:)
        Models::AdditionalAttribute.where(sip: sip, key: key).pluck(:value)
      end
      module_function :sip_attribute_values_for
      public :sip_attribute_values_for

      def sip_attribute_key_value_pairs(sip:, keys: [])
        query = Models::AdditionalAttribute.where(sip: sip).order(:sip_id, :key)
        query = query.where(key: keys) if keys.present?
        query.pluck(:key, :value)
      end
      module_function :sip_attribute_key_value_pairs
      public :sip_attribute_key_value_pairs

      def sip_attribute_keys_for(sip:)
        Models::AdditionalAttribute.where(sip: sip).order(:key).pluck('DISTINCT key')
      end
      module_function :sip_attribute_keys_for
      public :sip_attribute_keys_for

      def sip_default_attribute_keys_for(*)
        [:publication_date]
      end
      module_function :sip_default_attribute_keys_for
      public :sip_default_attribute_keys_for
    end
  end
end
