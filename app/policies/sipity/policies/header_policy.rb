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

      def default_permission_query_service
        lambda do |options|
          Models::Permission.
            where(actor: options.fetch(:user), entity: options.fetch(:entity), role: options.fetch(:roles)).any?
        end
      end

      # Responsible for building a scoped query to find a collection of
      # Model::Header objects for the given user.
      #
      # Responsible for answering.
      #
      # @see [Pundit gem scopes](https://github.com/elabs/pundit#scopes) for
      #   more information regarding the Scope interface.
      class Scope
        def self.resolve(user:, scope: Models::Header)
          new(user, scope).resolve
        end
        def initialize(user, scope = Models::Header)
          @user = user
          @scope = scope
        end
        attr_reader :user, :scope
        private :user, :scope

        # Switching to AREL
        # @see [AREL gem](https://github.com/rails/arel) for information on
        #   constructing AREL queries
        def resolve
          scope.where(
            scope.arel_table[:id].in(user_permission_subquery).
            or(scope.arel_table[:id].in(group_permission_subquery))
          )
        end

        private

        # Responsible for returning entity ids to which the user has direct
        # access.
        def user_permission_subquery(perm_table = Models::Permission.arel_table)
          # For user based queries
          perm_table.project(perm_table[:entity_id]).where(
            perm_table[:actor_id].eq(polymorphic_user_as_actor_id).
            and(perm_table[:actor_type].eq(polymorphic_user_as_actor_type)).
            and(perm_table[:role].in(permitted_roles)).
            and(perm_table[:entity_type].eq(polymorphic_entity_type))
          )
        end

        # Responsible for returning entity ids to which the user has direct
        # inferred access based on group membership.
        def group_permission_subquery(perm_table = Models::Permission.arel_table)
          perm_table.project(perm_table[:entity_id]).where(
            perm_table[:role].in(permitted_roles).
            and(perm_table[:entity_type].eq(polymorphic_entity_type)).
            and(perm_table[:actor_type].eq(polymorphic_group_as_actor_type)).
            and(perm_table[:actor_id].in(user_group_membership_subquery))
          )
        end

        # Responsible for returning group ids to which the user belongs.
        def user_group_membership_subquery(membership_table = Models::GroupMembership.arel_table)
          membership_table.project(membership_table[:group_id]).
            where(membership_table[:user_id].eq(polymorphic_user_as_actor_id))
        end

        def permitted_roles
          [Models::Permission::CREATING_USER]
        end

        def polymorphic_user_as_actor_id
          user.to_key
        end

        def polymorphic_user_as_actor_type
          # I Believe this is the correct way to handle the polymorphic relation
          # on Models::Permission
          user.class.base_class
        end

        def polymorphic_group_as_actor_type
          # I Believe this is the correct way to handle the polymorphic relation
          # on Models::Permission
          Models::Group.base_class
        end

        def polymorphic_entity_type
          # I Believe this is the correct way to handle the polymorphic relation
          # on Models::Permission
          scope.base_class
        end
      end
    end
  end
end
