module Sipity
  module Conversions
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToProcessingEntity
      def self.call(input)
        convert_to_processing_entity(input)
      end

      def convert_to_processing_entity(input)
        return input if input.is_a?(Models::Processing::Entity)
        return input.to_processing_entity if input.respond_to?(:to_processing_entity)
        return convert_to_processing_entity(input.entity) if input.is_a?(Models::Processing::Comment)
        raise Exceptions::ProcessingEntityConversionError, input
      end

      module_function :convert_to_processing_entity
      private_class_method :convert_to_processing_entity
      private :convert_to_processing_entity
    end
  end
end
