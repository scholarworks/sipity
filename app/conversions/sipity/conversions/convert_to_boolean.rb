module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # boolean. This is important because user input can come in the form of
    # 'true', 'false', '0', '1'.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToBoolean
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      #
      # @param input [Object] something coercable
      #
      # @return Boolean
      #
      # @see #convert_to_boolean
      def self.call(input)
        convert_to_boolean(input)
      end

      # Does its best to convert the input into a Boolean.
      #
      # @param input [Object] something coercable
      #
      # @return Boolean
      def convert_to_boolean(input)
        case input
        when false, 0, '0', 'false', 'no', nil then false
        else
          true
        end
      end

      module_function :convert_to_boolean
      private_class_method :convert_to_boolean
      private :convert_to_boolean
    end
  end
end
