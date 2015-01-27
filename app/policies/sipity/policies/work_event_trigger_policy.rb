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
        return false unless work.persisted?
      end

      alias_method :form, :entity
      attr_reader :work

      private

      def entity=(object)
        if object.respond_to?(:work) && object.work.present?
          super(object)
          @work = object.work
        else
          fail Exceptions::PolicyEntityExpectationError, "Expected #{object} to have a #work."
        end
      end
    end
  end
end
