module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it the
    # polymorphic base class.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToPolymorphicType
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      def self.call(input)
        convert_to_polymorphic_type(input)
      end

      # Does its best to convert the input into a year.
      #
      # @param input [Object] something coercable
      #
      # @return Integer
      def convert_to_polymorphic_type(input)
        return input.to_polymorphic_type if input.respond_to?(:to_polymorphic_type)
        return input.base_class if input.respond_to?(:base_class)
        return input.class.base_class if input.is_a?(ActiveRecord::Base)
        raise Exceptions::EntityTypeConversionError, input
      end

      module_function :convert_to_polymorphic_type
      private_class_method :convert_to_polymorphic_type
      private :convert_to_polymorphic_type
    end
  end
end
