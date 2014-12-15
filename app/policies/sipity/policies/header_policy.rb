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
            where(user: options.fetch(:user), entity: options.fetch(:entity), role: options.fetch(:roles)).any?
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
          scope.where(scope.arel_table[:id].in(permission_subquery))
        end

        private

        def permission_subquery(arel_table = Models::Permission.arel_table)
          arel_table.project(arel_table[:id]).where(
            arel_table[:user_id].eq(user.to_key).
            and(arel_table[:role].in([Models::Permission::CREATING_USER])).
            and(arel_table[:entity_type].eq(polymorphic_entity_type))
          )
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
