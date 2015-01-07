module Sipity
  # :nodoc:
  module Commands
    # Commands
    module AdditionalAttributeCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::AdditionalAttributeQueries)
      end

      def update_sip_publication_date!(sip:, publication_date:)
        return true unless publication_date.present?
        update_sip_attribute_values!(
          sip: sip, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, values: publication_date
        )
      end
      module_function :update_sip_publication_date!
      public :update_sip_publication_date!

      def update_sip_attribute_values!(sip:, key:, values:)
        input_values = Array.wrap(values)
        existing_values = Queries::AdditionalAttributeQueries.sip_attribute_values_for(sip: sip, key: key)
        create_sip_attribute_values!(sip: sip, key: key, values: (input_values - existing_values))
        destroy_sip_attribute_values!(sip: sip, key: key, values: (existing_values - input_values))
      end
      module_function :update_sip_attribute_values!
      public :update_sip_attribute_values!

      def create_sip_attribute_values!(sip:, key:, values:)
        Array.wrap(values).each do |value|
          Models::AdditionalAttribute.create!(sip: sip, key: key, value: value)
        end
      end
      module_function :create_sip_attribute_values!
      public :create_sip_attribute_values!

      def destroy_sip_attribute_values!(sip:, key:, values:)
        values_to_destroy = Array.wrap(values)
        return true unless values_to_destroy.present?
        Models::AdditionalAttribute.where(sip: sip, key: key, value: values_to_destroy).destroy_all
      end

      module_function :destroy_sip_attribute_values!
      public :destroy_sip_attribute_values!
    end
    private_constant :AdditionalAttributeCommands
  end
end
