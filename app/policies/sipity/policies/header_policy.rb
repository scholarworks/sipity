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
        @permission_query_service = permission_query_service || defaul_permission_query_service
      end
      attr_reader :user, :header, :permission_query_service
      private :user, :header, :permission_query_service

      def show?
        return false unless user.present?
        return false unless header.persisted?
        permission_query_service.call(user: user, subject: header, roles: ['creating_user'])
      end

      def update?
        return false unless user.present?
        return false unless header.persisted?
        permission_query_service.call(user: user, subject: header, roles: ['creating_user'])
      end

      def create?
        return false unless user.present?
        return false if header.persisted?
        true
      end

      def destroy?
        return false unless user.present?
        return false unless header.persisted?
        permission_query_service.call(user: user, subject: header, roles: ['creating_user'])
      end

      private

      def defaul_permission_query_service
        lambda do |options|
          # TODO: Extract this method into a permssions object
          Models::Permission.where(user: options(:user), subject: options.fetch(:header)).
            where("roles IN ?", options.fetch(:roles)).any?
        end
      end
    end
  end
end
