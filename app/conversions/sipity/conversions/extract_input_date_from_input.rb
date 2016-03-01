module Sipity
  module Conversions
    # A module to contain a utility function for working with Rails input dates
    module ExtractInputDateFromInput
      private

      # @api public
      #
      # A helper function for extracting Rails input conventions from user input.
      #
      # When Rails builds a date input for form (without javascript), it is
      # rendered as three select boxes with names of:
      #
      # * field_name(1i): For the year
      # * field_name(2i): For the month
      # * field_name(3i): For the day
      #
      # However, it is possible that we would get the field values as a date
      # format (thank you JS libraries), we need to handle that case as well.
      #
      # @param key [Symbol,String] The key that you are going to attempt to extract from the input
      # @param input [Hash] The input hash that perhaps contains the key
      #
      # @return nil if the key does not exist
      # @return String if the key does exist
      # @return yielded value if a block was given and the key did not exist in the input
      # @yield if the key does not exist in the input
      #
      # @see Underlying tests for the specifications on how this runs.
      def extract_input_date_from_input(key, input)
        attributes = input.with_indifferent_access
        if attributes.key?(key)
          attributes.fetch(key)
        elsif attributes.key?("#{key}(1i)") && attributes.key?("#{key}(2i)") && attributes.key?("#{key}(3i)")
          [attributes["#{key}(1i)"].to_i.to_s, attributes["#{key}(2i)"].to_i.to_s, attributes["#{key}(3i)"].to_i.to_s].join('-')
        else
          block_given? ? yield : nil
        end
      end
    end
  end
end
