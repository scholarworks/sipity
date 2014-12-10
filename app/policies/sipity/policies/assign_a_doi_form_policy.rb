module Sipity
  module Policies
    # Responsible for enforcing Assignment of a DOI
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    # @see HeaderPolicy for more information on who can edit this object.
    class AssignADoiFormPolicy < BasePolicy
      attr_reader :header_policy
      private :header_policy
      def initialize(user, entity, options = {})
        super(user, entity)
        @header_policy = options.fetch(:header_policy) { default_header_policy }
      end

      def submit?
        return false unless user.present?
        return false unless entity.header.persisted?
        header_policy.update?
      end

      private

      def default_header_policy
        HeaderPolicy.new(user, entity.header)
      end
    end
  end
end
