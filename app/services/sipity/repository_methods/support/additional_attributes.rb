module Sipity
  module RepositoryMethods
    module Support
      # Responsible for managing Additional Attributes
      module AdditionalAttributes
        module_function

        def update!(header:, key:, values:)
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          AdditionalAttributeMethods.update_header_attribute_values!(header: header, key: key, values: values)
        end

        def create!(header:, key:, values:)
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          AdditionalAttributeMethods.create_header_attribute_values!(header: header, key: key, values: values)
        end

        def destroy!(header:, key:, values:)
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          AdditionalAttributeMethods.destroy_header_attribute_values!(header: header, key: key, values: values)
        end

        def values_for(header:, key:)
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          AdditionalAttributeMethods.header_attribute_values_for(header: header, key: key)
        end

        def key_value_pairs_for(header:, keys: [])
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          AdditionalAttributeMethods.header_attribute_key_value_pairs(header: header, keys: keys)
        end

        def keys_for(header:)
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          AdditionalAttributeMethods.header_attribute_keys_for(header: header)
        end

        def default_keys_for(*args)
          ActiveSupport::Deprecation.warn("#{self}##{__method__} is deprecated")
          AdditionalAttributeMethods.header_default_attribute_keys_for(*args)
        end
      end
    end
  end
end
