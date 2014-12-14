module Sipity
  module Services
    # A service object to find and enforce appropriate policies.
    class AuthorizationLayer
      def initialize(context, collaborators = {})
        @context = context
        @user = context.current_user
        @policy_authorizer = collaborators.fetch(:policy_authorizer) { default_policy_authorizer }
      end
      attr_reader :user, :context, :policy_authorizer
      private :user, :context, :policy_authorizer

      # Responsible for enforcing policies on the :policy_questions_and_entity_pairs.
      #
      # @param policy_questions_and_entity_pairs [Hash<Symbol,Object>, #each] Yield two elements a
      #   :policy_question and an :entity
      #
      # @yield Returns control to the caller if all :policy_questions_and_entity_pairs
      #   are authorized.
      #
      # @raise [Exceptions::AuthorizationFailureError] if one of the
      #   policy_question/entity pairs fail to authorize.
      #
      # @note If the context implements #callbacks, that will be called.
      #
      # @todo Would it be helpful to include in the exception the policy_enforcer
      #   that was found?
      def enforce!(policy_questions_and_entity_pairs = {})
        policy_questions_and_entity_pairs.each do |policy_question, entity|
          next if policy_authorizer.call(user: user, policy_question: policy_question, entity: entity)
          context.callback(:unauthorized) if context.respond_to?(:callback)
          fail Exceptions::AuthorizationFailureError, user: user, policy_question: policy_question, entity: entity
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
