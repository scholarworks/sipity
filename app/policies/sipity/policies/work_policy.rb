module Sipity
  module Policies
    # Responsible for enforcing access to a given Sipity::Work.
    #
    # This class answers can I take the given action based on the user and
    # the work.
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    class WorkPolicy < BasePolicy
      def initialize(user, work, permission_query_service: nil)
        super(user, work)
        @permission_query_service = permission_query_service || default_permission_query_service
      end
      attr_reader :permission_query_service, :original_entity
      private :permission_query_service, :original_entity

      define_action_to_authorize :show? do
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, entity: entity, acting_as: [Models::Permission::CREATING_USER])
      end

      define_action_to_authorize :update? do
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, entity: entity, acting_as: [Models::Permission::CREATING_USER])
      end

      define_action_to_authorize :create? do
        return false unless user.present?
        return false if entity.persisted?
        true
      end

      define_action_to_authorize :destroy? do
        return false unless user.present?
        return false unless entity.persisted?
        permission_query_service.call(user: user, entity: entity, acting_as: [Models::Permission::CREATING_USER])
      end

      private

      # TODO: Work with underlying Scoping query
      def default_permission_query_service
        lambda do |options|
          Models::Permission.
            where(actor: options.fetch(:user), entity: options.fetch(:entity), acting_as: options.fetch(:acting_as)).any?
        end
      end

      # Responsible for building a scoped query to find a collection of
      # Model::Work objects for the given user.
      #
      # Responsible for answering the following:
      #
      # Given a user and an array of how the user could be acting, what are all the entities
      # within the scope that I can "see"
      #
      # @see [Pundit gem scopes](https://github.com/elabs/pundit#scopes) for
      #   more information regarding the Scope interface.
      class Scope
        def self.resolve(options = {})
          user = options.fetch(:user)
          scope = options.fetch(:scope) { Models::Work }
          new(user, scope, options.slice(:acting_as, :repository)).resolve(options)
        end

        def initialize(user, scope, options = {})
          @user = user
          @scope = scope
          @repository = options.fetch(:repository) { default_repository }
        end

        attr_reader :user, :scope, :repository
        private :user, :scope, :repository

        def resolve(options = {})
          resolved_scope = repository.scope_proxied_objects_for_the_user_and_proxy_for_type(user: user, proxy_for_type: scope)
          processing_state = options.fetch(:processing_state, nil)
          if processing_state.present?
            resolved_scope.where(processing_state: processing_state)
          else
            resolved_scope
          end
        end

        private

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
