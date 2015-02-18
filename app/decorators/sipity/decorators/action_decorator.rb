module Sipity
  module Decorators
    # Responsible for building a Processing Decorator
    module ActionDecorator
      module_function

      def build(options = {})
        action = options.fetch(:action)
        decorator_class = "Sipity::Decorators::Processing::#{action.action_type.classify}Decorator".constantize
        decorator_class.new(options)
      end
    end
  end
end
