require 'sipity/conversions/convert_to_work'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Queries
    # Queries
    # TODO: These methods need to no longer be module_functions; I believe the
    #   direction is to look towards creating service objects.
    module AdditionalAttributeQueries
      def work_attribute_values_for(work:, key:, cardinality: :many)
        work = Conversions::ConvertToWork.call(work)
        scope = Models::AdditionalAttribute.where(work_id: work.id, key: key)
        scope = scope.limit(cardinality) unless cardinality == :many
        scope.pluck(:value)
      end

      def work_attribute_key_value_pairs(work:, keys: [])
        work = Conversions::ConvertToWork.call(work)
        query = Models::AdditionalAttribute.where(work_id: work.id).order(:work_id, :key)
        query = query.where(key: Array.wrap(keys)) if keys.present?
        query.pluck(:key, :value)
      end
    end
  end
end
