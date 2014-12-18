module Sipity
  module Policies
    # Responsible for enforcing access to a given Sipity::Header.
    #
    # This class answers can I take the given action based on the user and
    # the header.
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    class HeaderPolicy < BasePolicy
      def initialize(user, header, permission_query_service: nil)
        super(user, header)
        @permission_query_service = permission_query_service || default_permission_query_service
      end
      attr_reader :permission_query_service, :original_entity
      private :permission_query_service, :original_entity

      define_policy_question :show? do
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, entity: entity, roles: [Models::Permission::CREATING_USER])
      end

      define_policy_question :update? do
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, entity: entity, roles: [Models::Permission::CREATING_USER])
      end

      define_policy_question :create? do
        return false unless user.present?
        return false if entity.persisted?
        true
      end

      define_policy_question :destroy? do
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, entity: entity, roles: [Models::Permission::CREATING_USER])
      end

      private

      # TODO: Work with underlying Scoping query
      def default_permission_query_service
        lambda do |options|
          Models::Permission.
            where(actor: options.fetch(:user), entity: options.fetch(:entity), role: options.fetch(:roles)).any?
        end
      end

      # Responsible for building a scoped query to find a collection of
      # Model::Header objects for the given user.
      #
      # Responsible for answering the following:
      #
      # Given a user and an array of permitted roles, what are all the entities
      # within the scope that I can "see"
      #
      # @see [Pundit gem scopes](https://github.com/elabs/pundit#scopes) for
      #   more information regarding the Scope interface.
      class Scope
        def self.resolve(user:, scope: Models::Header, permitted_roles: [Models::Permission::CREATING_USER])
          new(user, scope, permitted_roles: permitted_roles).resolve
        end
        def initialize(user, scope = Models::Header, permitted_roles: [Models::Permission::CREATING_USER])
          @user = user
          @scope = scope
          @permitted_roles = permitted_roles
        end
        attr_reader :user, :scope, :permitted_roles
        private :user, :scope, :permitted_roles

        def resolve
          Queries::PermissionQueries.scope_permission_resolver(user: user, entity_type: scope, roles: permitted_roles)
        end
      end
    end
  end
end
