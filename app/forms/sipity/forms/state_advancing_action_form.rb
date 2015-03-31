module Sipity
  module Forms
    # A form that is submitted to advance the processing state of a processible
    # entity.
    #
    # @see Sipity::Models::Processing::StrategyAction
    class StateAdvancingActionForm < ProcessingActionForm
      def initialize(attributes = {})
        super
        self.action = attributes.fetch(:processing_action_name) { default_processing_action_name }
      end

      attr_reader :action

      delegate :resulting_strategy_state, to: :action

      def processing_action_name
        action.name
      end

      private

      def enrichment_type
        self.class.to_s.demodulize.underscore.sub(/_form\Z/i, '')
      end
      alias_method :default_processing_action_name, :enrichment_type

      include Conversions::ConvertToProcessingAction
      def action=(value)
        @action = convert_to_processing_action(value, scope: to_processing_entity)
      end
    end
  end
end
