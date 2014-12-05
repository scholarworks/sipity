module Sipity
  module Repo
    # Methods for checking policies
    module PolicyMethods
      def policy_unauthorized_for?(runner:, subject:)
        current_user = runner.current_user
        policy_method_name = find_policy_method_name_for(runner)
        policy_class = find_policy_class_for(subject)
        !policy_class.new(current_user, subject).public_send(policy_method_name)
      end

      def find_policy_class_for(context)
        if context.respond_to?(:policy_class) && context.policy_class.present?
          context.policy_class
        else
          # Yowza! This could cause lots of problems; Maybe I should be very
          # specific about this?
          Policies.const_get("#{context.class.to_s.demodulize}Policy")
        end
      end

      def find_policy_method_name_for(context)
        if context.respond_to?(:policy_method_name)
          context.policy_method_name
        else
          # Yowza! Maybe I should be specific about this?
          "#{context.class.to_s.demodulize.underscore}?"
        end
      end
    end
  end
end
