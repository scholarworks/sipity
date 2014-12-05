module Sipity
  module Repo
    # Methods for checking policies
    module PolicyMethods
      def policy_unauthorized_for?(runner:, subject:)
        current_user = runner.current_user
        policy_class = find_policy_class_for(subject)
        !policy_class.new(current_user, subject).public_send(runner.policy_authorization_method_name)
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
    end
  end
end
