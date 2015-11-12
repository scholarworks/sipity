require 'sipity/conversions/convert_to_work'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Queries
    # Queries
    # TODO: These methods need to no longer be module_functions; I believe the
    #   direction is to look towards creating service objects.
    module AdditionalAttributeQueries
      # @api public
      #
      # Responsible for returning the values associated with the given :work and :key.
      #
      # @param work [#to_work] The containing work
      # @param key [#to_s] The named predicate (yes it should be :predicate_name and not :key) to retrieve values for
      # @param cardinality [:many, :one, #to_i] The maximum number to include
      #
      # @return Array or Object depending on cardinality
      #
      # @review Consider not using cardinality and instead preferring specific methods? This could mean an explosion.
      def work_attribute_values_for(work:, key:, cardinality: :many)
        work = Conversions::ConvertToWork.call(work)
        scope = Models::AdditionalAttribute.where(work_id: work.id, key: key)
        scope = scope.limit(cardinality) unless cardinality == :many
        returning_value = scope.pluck(:value)
        returning_value = returning_value.first if cardinality == :one || cardinality == 1
        returning_value
      end
    end
  end
end
