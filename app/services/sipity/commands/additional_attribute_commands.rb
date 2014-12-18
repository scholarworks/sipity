module Sipity
  module Commands
    # Commands
    module AdditionalAttributeCommands
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Queries::AdditionalAttributeQueries)
      end

      def update_header_publication_date!(header:, publication_date:)
        return true unless publication_date.present?
        update_header_attribute_values!(
          header: header, key: Models::AdditionalAttribute::PUBLICATION_DATE_PREDICATE_NAME, values: publication_date
        )
      end
      module_function :update_header_publication_date!
      public :update_header_publication_date!

      def update_header_attribute_values!(header:, key:, values:)
        input_values = Array.wrap(values)
        existing_values = Queries::AdditionalAttributeQueries.header_attribute_values_for(header: header, key: key)
        create_header_attribute_values!(header: header, key: key, values: (input_values - existing_values))
        destroy_header_attribute_values!(header: header, key: key, values: (existing_values - input_values))
      end
      module_function :update_header_attribute_values!
      public :update_header_attribute_values!

      def create_header_attribute_values!(header:, key:, values:)
        Array.wrap(values).each do |value|
          Models::AdditionalAttribute.create!(header: header, key: key, value: value)
        end
      end
      module_function :create_header_attribute_values!
      public :create_header_attribute_values!

      def destroy_header_attribute_values!(header:, key:, values:)
        values_to_destroy = Array.wrap(values)
        return true unless values_to_destroy.present?
        Models::AdditionalAttribute.where(header: header, key: key, value: values_to_destroy).destroy_all
      end

      module_function :destroy_header_attribute_values!
      public :destroy_header_attribute_values!
    end
    private_constant :AdditionalAttributeCommands
  end
end
