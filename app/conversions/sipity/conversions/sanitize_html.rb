require 'sanitize'

module Sipity
  module Conversions
    # Exposes a conversion method to take a string or text and convert it to
    # a safe subset of HTML for display purposes.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module SanitizeHtml
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      #
      # @param input [Object] something textual
      #
      # @return String containing HTML
      #
      # @see #convert_to_boolean
      def self.call(input)
        sanitize_html(input)
      end

      # Does its best to convert the input into a Boolean.
      #
      # @param input [Object] something in html
      #
      # @return String containing HTML after sanitizing
      def sanitize_html(input)
        return '' if input.nil?
        Sanitize.clean(input.to_s, Sanitize::Config::RELAXED).html_safe
      end

      module_function :sanitize_html
      private_class_method :sanitize_html
      private :sanitize_html
    end
  end
end
