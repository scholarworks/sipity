module Sipity
  module DataGenerators
    # Responsible for validating the given data against the given schema
    module SchemaValidator
      # @param data [Hash]
      # @param schema [#call]
      #
      # @return true if the data validates from the schema
      # @raise Exceptions::InvalidSchemaError if the data does not validate against the schema
      def self.call(data:, schema:)
        validation = schema.call(data)
        return true unless validation.messages.present?
        fail Exceptions::InvalidSchemaError, errors: validation.messages
      end
    end
  end
end
