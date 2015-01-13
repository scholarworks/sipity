module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # URL that the web application's maintainer pinky promises will resolve long
    # into the future.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
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
        return convert_to_permanent_uri(input.id) if input.is_a?(Models::Sip)
        return convert_to_permanent_uri(input.work_id) if input.respond_to?(:work_id)
        return convert_to_permanent_uri(input.work) if input.respond_to?(:work)
        # TODO: The Work key may not be a Fixed num
        return PERMANENT_URI_FORMAT % input if input.is_a?(Fixnum)
        fail Exceptions::PermanentUriConversionError, input
      end

      module_function :convert_to_permanent_uri
      private_class_method :convert_to_permanent_uri
      private :convert_to_permanent_uri
    end
  end
end
