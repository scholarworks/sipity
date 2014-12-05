module Sipity
  module Repo
    # Methods for checking policies
    module PolicyMethods
      def policy_unauthorized_for?(runner:, entity:)
        current_user = runner.current_user
        policy_enforcer = find_policy_enforcer_for(entity)

        # The enforcer returns true but since this question is asking
        # are you unauthorized, I want to return the inverse
        !policy_enforcer.call(
          user: current_user, entity: entity,
          policy_question: runner.policy_question
        )
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
