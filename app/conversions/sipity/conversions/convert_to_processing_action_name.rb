module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # a processing action name.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToProcessingActionName
      RESOURCEFUL_ACTION_MAP = {
        'update' => 'edit',
        'create' => 'new'
      }.freeze

      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      def self.call(input)
        convert_to_processing_action_name(input)
      end

      # Does its best to convert the input into a processing action name.
      #
      # This is necessary as sometimes we will have paired controller action
      # name (i.e. edit/update) that represent the same permission concept.
      #
      # @param input [Object] something coercable
      #
      # @return String
      # @see Sipity::Models::Processing::StrategyAction#name
      def convert_to_processing_action_name(input)
        return input.to_processing_action_name if input.respond_to?(:to_processing_action_name)
        case input
        when String, Symbol
          input_without_punctuation = input.to_s.sub(/[\?\!]\Z/, '')
          RESOURCEFUL_ACTION_MAP.fetch(input_without_punctuation, input_without_punctuation)
        when Models::Processing::StrategyAction
          input.name
        else
          raise Exceptions::ProcessingActionNameConversionError, input
        end
      end

      module_function :convert_to_processing_action_name
      private_class_method :convert_to_processing_action_name
      private :convert_to_processing_action_name
    end
  end
end
