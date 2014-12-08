module Sipity
  module Repo
    # Methods for checking policies
    module PolicyMethods
      def policy_authorized_for?(user:, policy_question:, entity:)
        policy_enforcer = find_policy_enforcer_for(entity)
        policy_enforcer.call(user: user, entity: entity, policy_question: policy_question)
      end

      def find_policy_enforcer_for(context)
        if context.respond_to?(:policy_enforcer) && context.policy_enforcer.present?
          context.policy_enforcer
        else
          # Yowza! This could cause lots of problems; Maybe I should be very
          # specific about this?
          Policies.const_get("#{context.class.to_s.demodulize}Policy")
        end
      end
    end
  end
end
