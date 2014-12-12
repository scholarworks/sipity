module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # URL that the web application's maintainer pinky promises will resolve long
    # into the future.
    module ConvertToPermanentUri
      PERMANENT_URI_FORMAT = "https://change.me/show/%s".freeze

      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      def self.call(input)
        convert_to_permanent_uri(input)
      end

      # Does its best to convert the input into a permanent url.
      #
      # @param input [Object] something coercable
      #
      # @return Integer
      def convert_to_permanent_uri(input)
        return convert_to_permanent_uri(input.id) if input.is_a?(Models::Header)
        return convert_to_permanent_uri(input.header_id) if input.respond_to?(:header_id)
        return convert_to_permanent_uri(input.header) if input.respond_to?(:header)
        # TODO: The Header key may not be a Fixed num
        return PERMANENT_URI_FORMAT % input if input.is_a?(Fixnum)
        fail Exceptions::PermanentUriConversionError, input
      end

      module_function :convert_to_permanent_uri
      private_class_method :convert_to_permanent_uri
      private :convert_to_permanent_uri
    end
  end
end
