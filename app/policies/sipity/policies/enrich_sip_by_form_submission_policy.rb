module Sipity
  module Policies
    # Responsible for enforcing Assignment of a DOI
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    # @see SipPolicy for more information on who can edit this object.
    class EnrichSipByFormSubmissionPolicy < BasePolicy
      attr_reader :sip_policy
      private :sip_policy
      def initialize(user, entity, options = {})
        super(user, entity)
        @sip_policy = options.fetch(:sip_policy) { default_sip_policy }
      end

      define_action_to_authorize :submit? do
        return false unless user.present?
        return false unless entity.sip.persisted?
        sip_policy.update?
      end

      private

      def entity=(object)
        if object.respond_to?(:sip) && object.sip.present?
          super(object)
        else
          fail Exceptions::PolicyEntityExpectationError, "Expected #{object} to have a #sip."
        end
      end

      def default_sip_policy
        SipPolicy.new(user, entity.sip)
      end
    end
  end
end
