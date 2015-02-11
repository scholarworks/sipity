module Sipity
  module Policies
    # Responsible for enforcing Assignment of a DOI
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    # @see WorkPolicy for more information on who can edit this object.
    class EnrichWorkByFormSubmissionPolicy < BasePolicy
      attr_reader :work_policy
      private :work_policy
      def initialize(user, entity, options = {})
        super(user, entity)
        @work_policy = options.fetch(:work_policy) { default_work_policy }
      end

      define_action_to_authorize :submit? do
        return false unless user.present?
        return false unless entity.work.persisted?
        work_policy.update?
      end

      private

      def entity=(object)
        if object.respond_to?(:work) && object.work.present? && object.respond_to?(:enrichment_type) && object.enrichment_type.present?
          super(object)
        else
          fail Exceptions::PolicyEntityExpectationError, "Expected #{object} to have a #work and #enrichment_type."
        end
      end

      def default_work_policy
        WorkPolicy.new(user, entity.work)
      end
    end
  end
end
