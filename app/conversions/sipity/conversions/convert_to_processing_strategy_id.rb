module Sipity
  module Conversions
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToProcessingStrategyId
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      def self.call(input)
        convert_to_processing_strategy_id(input)
      end

      # Does its best to convert the input into a processing stategy_id.
      #
      # @note Why not the ProcessingStrategy? I'm thinking about reducing the
      #   number of queries; I also understand that I will likely have a
      #   Processing::Entity instead of a Strategy
      #
      # @param input [Object] something coercable
      #
      # @return Integer
      def convert_to_processing_strategy_id(input)
        case input
        when Models::Processing::Strategy then return input.id
        when Integer then return input
        when String then return input.to_i
        end
        return input.strategy_id if input.respond_to?(:strategy_id)
        begin
          return convert_to_processing_strategy_id(ConvertToProcessingEntity.call(input))
        rescue Exceptions::ProcessingEntityConversionError
          nil
        end
        raise Exceptions::ProcessingStrategyIdConversionError, input
      end

      module_function :convert_to_processing_strategy_id
      private_class_method :convert_to_processing_strategy_id
      private :convert_to_processing_strategy_id
    end
  end
end
