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
      policy_enforcer = find_policy_enforcer_for(entity: entity)
      policy_enforcer.call(user: user, entity: entity, policy_question: policy_question)
    end

    def find_policy_enforcer_for(entity:)
      return entity.policy_enforcer if entity.respond_to?(:policy_enforcer) && entity.policy_enforcer.present?
      policy_name_as_constant = "#{entity.class.to_s.demodulize}Policy"
      if const_defined?(policy_name_as_constant)
        const_get(policy_name_as_constant)
      else
        fail Exceptions::PolicyNotFoundError, name: policy_name_as_constant, container: self
      end
    end
  end
end
