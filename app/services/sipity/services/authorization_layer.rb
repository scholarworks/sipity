module Sipity
  module Services
    # A service object to find and enforce appropriate policies.
    #
    # @see Sipity::Policies
    class AuthorizationLayer
      def initialize(context, collaborators = {})
        @context = context
        @user = context.current_user
        @policy_authorizer = collaborators.fetch(:policy_authorizer) { default_policy_authorizer }
      end
      attr_reader :user, :context, :policy_authorizer
      private :user, :context, :policy_authorizer

      # Responsible for enforcing policies on the :action_to_authorizes_and_entity_pairs.
      #
      # @param action_to_authorizes_and_entity_pairs [Hash<Symbol,Object>, #each] Yield two elements a
      #   :action_to_authorize and an :entity
      #
      # @yield Returns control to the caller if all :action_to_authorizes_and_entity_pairs
      #   are authorized.
      #
      # @raise [Exceptions::AuthorizationFailureError] if one of the
      #   action_to_authorize/entity pairs fail to authorize.
      #
      # @note If the context implements #callbacks, that will be called.
      #
      # @todo Would it be helpful to include in the exception the policy_enforcer
      #   that was found?
      def enforce!(action_to_authorizes_and_entity_pairs = {})
        action_to_authorizes_and_entity_pairs.each do |action_to_authorize, entity|
          next if policy_authorizer.call(user: user, action_to_authorize: action_to_authorize, entity: entity)
          context.callback(:unauthorized) if context.respond_to?(:callback)
          fail Exceptions::AuthorizationFailureError, user: user, action_to_authorize: action_to_authorize, entity: entity
        end
        yield
      end

      private

      def default_policy_authorizer
        Policies.method(:authorized_for?)
      end

      # Everything is allowed!
      class AuthorizeEverything
        def initialize(*)
        end

        def enforce!(*)
          yield
        end
      end
    end
  end
end
