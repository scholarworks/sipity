module Sipity
  # Contains the various Policies associated with Sipity.
  #
  # A Policy is an object responsible for answering questions about actions
  # the given user is attempting to take on a given object.
  #
  # @see [Elabs' Pundit gem](http://github.com/elabs/pundit) for
  #   further explanation of Policy and Scope objects.
  module Policies
    module_function

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
