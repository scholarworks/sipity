module Sipity
  module Models
    # The submodule that describes the sip processing phenomena.
    module Processing
      module_function

      # A method for composition; I'm going this route instead of the concerns.
      def configure_as_a_processible_entity(base_class)
        class_name = 'Sipity::Models::Processing::Entity'
        base_class.has_one(
          :processing_entity, -> { includes [:strategy_state, :strategy] }, as: :proxy_for, dependent: :destroy, class_name: class_name
        )

        base_class.delegate :processing_state, :processing_strategy, to: :processing_entity, allow_nil: true

        base_class.send(:define_method, :to_processing_entity) do
          # This is a bit of a short cut, perhaps I should check if its persisted?
          # But I'll settle for this right now.
          processing_entity || raise(Exceptions::ProcessingEntityConversionError, self)
        end
      end
    end
  end
end
