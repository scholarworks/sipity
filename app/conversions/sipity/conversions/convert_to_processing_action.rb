module Sipity
  module Conversions
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToProcessingAction
      def self.call(object, scope:)
        convert_to_processing_action(object, scope: scope)
      end

      def convert_to_processing_action(object, scope:)
        if object.is_a?(Models::Processing::StrategyAction)
          strategy_id = ConvertToProcessingStrategyId.call(scope)
          return object if object.strategy_id == strategy_id
        elsif object.is_a?(String) || object.is_a?(Symbol)
          strategy_id = ConvertToProcessingStrategyId.call(scope)
          strategy_action = Models::Processing::StrategyAction.find_by(strategy_id: strategy_id, name: object.to_s)
          return strategy_action if strategy_action.present?
        end
        fail Exceptions::ProcessingStrategyActionConversionError, { scope: scope, object: object }.inspect
      end

      module_function :convert_to_processing_action
      private_class_method :convert_to_processing_action
      private :convert_to_processing_action
    end
  end
end
