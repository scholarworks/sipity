module Sipity
  module Forms
    # A container module
    module Configure
      module_function

      def form_for_processing_entity(form_class:, base_class:)
        form_class.class_attribute :base_class unless form_class.respond_to?(:base_class=)
        form_class.base_class = base_class
        class << form_class
          delegate :model_name, :human_attribute_name, to: :base_class
        end
      end
    end
  end
end
