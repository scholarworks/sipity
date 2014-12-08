module Sipity
  module Policies
    # Responsible for enforcing access to a given Sipity::Header
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    class HeaderPolicy < BasePolicy
      def initialize(user, entity, permission_query_service: nil)
        super(user, entity)
        @permission_query_service = permission_query_service || default_permission_query_service
      end
      attr_reader :permission_query_service
      private :permission_query_service

      def show?
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, subject: entity, roles: [Models::Permission::CREATING_USER])
      end

      def update?
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, subject: entity, roles: [Models::Permission::CREATING_USER])
      end

      def create?
        return false unless user.present?
        return false if entity.persisted?
        true
      end

      def destroy?
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, subject: entity, roles: [Models::Permission::CREATING_USER])
      end

      private

      def default_permission_query_service
        lambda do |options|
          # TODO: Extract this method into a permissions object?
          Models::Permission.
            where(user: options.fetch(:user), subject: options.fetch(:subject), role: options.fetch(:roles)).any?
        end
      end
    end
  end
end
