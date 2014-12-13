module Sipity
  module Policies
    # At its core a policy must implement the following API
    #
    # * .call(user:, entity:, policy_question:)
    # * #initialize(user, entity)
    class BasePolicy
      # @param user [User]
      # @param entity [#persisted?]
      # @param policy_question [Symbol] In the general case this will be :show?,
      #   :create?, :update?, or :destroy?; However in other cases that may not
      #   be the correct answer.
      #
      # @return [Boolean] If the user can take the action, then return true.
      #   otherwise return false.
      def self.call(user:, entity:, policy_question:)
        new(user, entity).public_send(policy_question)
      end

      def initialize(user, entity)
        self.user = user
        self.entity = entity
      end
      attr_accessor :user, :entity
      private :user, :user=, :entity=, :entity
    end
  end
end
