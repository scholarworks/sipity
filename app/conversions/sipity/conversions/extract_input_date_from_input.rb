module Sipity
  module Conversions
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
    module ExtractInputDateFromInput
      private

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
