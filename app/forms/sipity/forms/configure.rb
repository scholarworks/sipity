module Sipity
  module Forms
    # A container module
    module Configure
      module_function

      def form_for_processing_entity(form_class:, base_class:, policy_enforcer: nil)
        policy_enforcer ||= base_class.name.sub(/::(\w+)::(\w+)\Z/, '::Policies::\2Policy').constantize
        form_class.class_attribute :base_class unless form_class.respond_to?(:base_class=)
        form_class.class_attribute :policy_enforcer unless form_class.respond_to?(:policy_enforcer=)
        form_class.base_class = base_class
        form_class.policy_enforcer = policy_enforcer
        class << form_class
          delegate :model_name, :human_attribute_name, to: :base_class
        end
      end
    end
  end
end
