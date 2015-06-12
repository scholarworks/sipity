module Sipity
  module Queries
    # Queries
    # TODO: These methods need to no longer be module_functions; I believe the
    #   direction is to look towards creating service objects.
    module AdditionalAttributeQueries
      def work_attribute_values_for(work:, key:)
        Models::AdditionalAttribute.where(work: work, key: key).pluck(:value)
      end

      def work_attribute_key_value_pairs(work:, keys: [])
        query = Models::AdditionalAttribute.where(work: work).order(:work_id, :key)
        query = query.where(key: keys) if keys.present?
        query.pluck(:key, :value)
      end
    end
  end
end
