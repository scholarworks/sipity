module Sipity
  module Forms
    # A container module
    module Configure
      module_function

      def form_for_processing_entity(form_class:, base_class:, **keywords)
        form_class.class_attribute :base_class unless form_class.respond_to?(:base_class=)
        form_class.base_class = base_class

        form_class.class_attribute :policy_enforcer unless form_class.respond_to?(:policy_enforcer=)
        form_class.policy_enforcer = keywords.fetch(:policy_enforcer) do
          base_class.name.sub(/::(\w+)::(\w+)\Z/, '::Policies::\2Policy').constantize
        end

        form_class.class_attribute :template unless form_class.respond_to?(:template=)
        form_class.template = keywords.fetch(:template) { form_class.name.demodulize.sub(/Form\Z/, '').underscore }

        class << form_class
          delegate :model_name, :human_attribute_name, to: :base_class
        end
      end
    end
  end
end
