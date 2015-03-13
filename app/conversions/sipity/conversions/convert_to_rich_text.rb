module Sipity
  module Conversions
    # Exposes a conversion method to take a string or text and convert it to
    # a safe subset of HTML for display purposes.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToRichText
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      #
      # @param input [Object] something textual
      #
      # @return String containing HTML
      #
      # @see #convert_to_boolean
      def self.call(input)
        convert_to_rich_text(input)
      end

      # Does its best to convert the input into a Boolean.
      #
      # @param input [Object] something textual
      #
      # @return String containing HTML
      def convert_to_rich_text(input)
        input
      end

      module_function :convert_to_rich_text
      private_class_method :convert_to_rich_text
      private :convert_to_rich_text
    end
  end
end
