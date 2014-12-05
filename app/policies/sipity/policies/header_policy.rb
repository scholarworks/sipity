module Sipity
  module Policies
    # Responsible for enforcing access to a given Sipity::Header
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    class HeaderPolicy < BasePolicy
      def show?
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, subject: entity, roles: ['creating_user'])
      end

      def update?
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, subject: entity, roles: ['creating_user'])
      end

      def create?
        return false unless user.present?
        return false if entity.persisted?
        true
      end

      def destroy?
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, subject: entity, roles: ['creating_user'])
      end
    end
  end
end
