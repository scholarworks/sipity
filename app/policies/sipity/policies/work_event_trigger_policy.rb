module Sipity
  module Policies
    # Responsible for enforcing a user attempting to trigger an event on
    # the given work.
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    # @see WorkPolicy for more information on who can edit this object.
    class WorkEventTriggerPolicy < BasePolicy
      define_action_to_authorize :submit? do
        return false unless user.present?
        return false unless entity.persisted?
      end
    end
  end
end
