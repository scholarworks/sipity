module Sipity
  # A service object to find and enforce appropriate policies.
  class AuthorizationLayer
    def initialize(context)
      @context = context
      @user = context.current_user
    end
    attr_reader :user, :context
    private :user, :context

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
        next if policy_authorized_for?(user: user, policy_question: policy_question, entity: entity)
        context.callback(:unauthorized) if context.respond_to?(:callback)
        fail Exceptions::AuthorizationFailureError, user: user, policy_question: policy_question, entity: entity
      end
      yield
    end

    private

    def policy_authorized_for?(user:, policy_question:, entity:)
      policy_enforcer = find_policy_enforcer_for(entity: entity)
      policy_enforcer.call(user: user, entity: entity, policy_question: policy_question)
    end

    def find_policy_enforcer_for(entity:)
      return entity.policy_enforcer if entity.respond_to?(:policy_enforcer) && entity.policy_enforcer.present?
      policy_name_as_constant = "#{entity.class.to_s.demodulize}Policy"
      if Policies.const_defined?(policy_name_as_constant)
        Policies.const_get(policy_name_as_constant)
      else
        fail Exceptions::PolicyNotFoundError, name: policy_name_as_constant, container: Policies
      end
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
