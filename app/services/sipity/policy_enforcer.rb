module Sipity
  # A service object to find and enforce appropriate policies.
  class PolicyEnforcer
    # Everything is allowed!
    class AuthorizeEverything
      def initialize(*)
      end

      def enforce!(*)
        yield
      end
    end
    def initialize(context)
      @context = context
      @user = context.current_user
    end
    attr_reader :user, :context
    private :user, :context

    def enforce!(policy_question, entity)
      if policy_authorized_for?(user: user, policy_question: policy_question, entity: entity)
        yield
      else
        context.callback(:unauthorized) if context.respond_to?(:callback)
        fail Exceptions::AuthorizationFailureError, user: user, policy_question: policy_question, entity: entity
      end
    end

    private

    def policy_authorized_for?(user:, policy_question:, entity:)
      policy_enforcer = find_policy_enforcer_for(entity)
      policy_enforcer.call(user: user, entity: entity, policy_question: policy_question)
    end

    def find_policy_enforcer_for(entity)
      if entity.respond_to?(:policy_enforcer) && entity.policy_enforcer.present?
        entity.policy_enforcer
      else
        # Yowza! This could cause lots of problems; Maybe I should be very
        # specific about this?
        Policies.const_get("#{entity.class.to_s.demodulize}Policy")
      end
    end
  end
end
