module Sipity
  module Repo
    # Methods for checking policies
    module PolicyMethods
      def policy_unauthorized_for?(runner:, entity:)
        current_user = runner.current_user
        policy_enforcer = find_policy_enforcer_for(entity)
        # TODO: Perhaps something a little less dense? And something that does
        # not violate the Law of Demeter
        !policy_enforcer.call(user: current_user, entity: entity, policy_authorization_method_name: policy_authorization_method_name)
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
