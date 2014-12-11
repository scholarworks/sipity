module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # year.
    module ConvertToYear
      private

      def convert_to_year(input)
        return input.to_year if input.respond_to?(:to_year)
        return input.year if input.respond_to?(:year)
        return convert_to_year(input.to_date) if input.respond_to?(:to_date)
        return convert_to_year(input.to_time) if input.respond_to?(:to_time)
      rescue ArgumentError
        return input.to_i == 0 ? nil : input.to_i if input.respond_to?(:to_i)
      end
    end
  end
end
