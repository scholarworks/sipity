module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # Sipity::Models::Processing::EntityActionRegister object.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToRegisteredAction
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      #
      # @param input [Object] something coercable
      #
      # @return [Sipity::Models::EntityActionRegister] (or something that follows
      #   to the Liskov Substitution Principle
      #   http://en.wikipedia.org/wiki/Liskov_substitution_principle)
      #
      # @see #convert_to_work
      def self.call(input)
        convert_to_registered_action(input)
      end

      # Does its best to convert the input into a Sipity::Models::Work object.
      #
      # @param input [Object] something coercable
      #
      # @return [Sipity::Models::Work] (or something that followsto the Liskov
      #   Substitution Principle
      #   http://en.wikipedia.org/wiki/Liskov_substitution_principle)
      #
      # @raise Exceptions::WorkConversionError
      def convert_to_registered_action(input)
        return input.to_registered_action if input.respond_to?(:to_registered_action)
        return input if input.is_a?(Models::Processing::EntityActionRegister)
        raise Exceptions::RegisteredActionConversionError, input
      end

      module_function :convert_to_registered_action
      private_class_method :convert_to_registered_action
      private :convert_to_registered_action
    end
  end
end
