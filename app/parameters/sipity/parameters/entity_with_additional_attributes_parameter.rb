require 'active_support/core_ext/array/wrap'

module Sipity
  module Parameters
    # A coordination parameter for gathering collecting an entity and its
    # comments.
    class EntityWithAdditionalAttributesParameter
      def initialize(entity:, additional_attributes:)
        self.entity = entity
        self.additional_attributes = additional_attributes
      end

      attr_reader :entity, :additional_attributes

      include Enumerable
      delegate :each, to: :additional_attributes

      private

      attr_writer :entity

      def additional_attributes=(input)
        @additional_attributes = Array.wrap(input).each_with_object({}) do |additional_attribute, mem|
          mem[additional_attribute.key] ||= AdditionalAttributeParameter.new(entity, additional_attribute.key, [])
          mem[additional_attribute.key].values << additional_attribute.value
        end.values
      end

      AdditionalAttributeParameter = Struct.new(:entity, :key, :values)
      private_constant :AdditionalAttributeParameter
    end
  end
end
