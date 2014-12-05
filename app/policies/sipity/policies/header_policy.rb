module Sipity
  module Policies
    # Responsible for enforcing access to a given Sipity::Header
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    class HeaderPolicy
      def initialize(user, header, permission_query_service: nil)
        @user = user
        @header = header
        @permission_query_service = permission_query_service
      end
      attr_reader :user, :header, :permission_query_service
      private :user, :header, :permission_query_service

      def show?
        return false unless user.present?
        return false unless header.persisted?
        permission_query_service.call(user: user, header: header, roles: ['creating_user'])
      end

      def update?
        return false unless user.present?
        return false unless header.persisted?
        permission_query_service.call(user: user, header: header, roles: ['creating_user'])
      end

      def create?
        return false unless user.present?
        return false if header.persisted?
        true
      end

      def destroy?
        return false unless user.present?
        return false unless header.persisted?
        permission_query_service.call(user: user, header: header, roles: ['creating_user'])
      end
    end
  end
end
