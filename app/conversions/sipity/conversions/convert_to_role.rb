module Sipity
  module Conversions
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToRole
      def self.call(input)
        convert_to_role(input)
      end

      def convert_to_role(input)
        PowerConverter.convert(input, to: :role)
      rescue PowerConverter::ConversionError
        raise Exceptions::RoleConversionError, input
      end

      module_function :convert_to_role
      private_class_method :convert_to_role
      private :convert_to_role
    end
  end
end
