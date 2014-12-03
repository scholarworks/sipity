module Sip
  module Repo
    module Support
      # Responsible for managing Additional Attributes
      module AdditionalAttributes
        module_function

        def update!(header:, key:, values:)
          input_values = Array.wrap(values)
          existing_values = values_for(header: header, key: key)
          create!(header: header, key: key, values: (input_values - existing_values))
          destroy!(header: header, key: key, values: (existing_values - input_values))
        end

        def create!(header:, key:, values:)
          Array.wrap(values).each do |value|
            AdditionalAttribute.create!(header: header, key: key, value: value)
          end
        end

        def destroy!(header:, key:, values:)
          values_to_destroy = Array.wrap(values)
          return true unless values_to_destroy.present?
          AdditionalAttribute.where(header: header, key: key, value: values_to_destroy).destroy_all
        end

        def values_for(header:, key:)
          AdditionalAttribute.where(header: header, key: key).pluck(:value)
        end

        def key_value_pairs_for(header:)
          AdditionalAttribute.where(header: header).order(:sip_header_id, :key).pluck(:key, :value)
        end

        def keys_for(header:)
          AdditionalAttribute.where(header: header).order(:key).pluck('DISTINCT key')
        end

        def default_keys_for(*)
          [:publication_date]
        end
      end
    end
  end
end
