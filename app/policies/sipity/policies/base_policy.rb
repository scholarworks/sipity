module Sipity
  module Policies
    # At its core a policy must implement the following API
    #
    # * .call(user:, entity:, policy_question:)
    # * #initialize(user, entity)
    class BasePolicy
      # @param user [User]
      # @param entity [#persisted?]
      # @param policy_question [Symbol] In the general case
      #   this will be :show?, :create?, :update?, or :destroy?; However in
      #   other cases that may not be the correct answer.
      #
      # @return [Boolean] If the user can take the action, then return true.
      #   otherwise return false.
      def self.call(user:, entity:, policy_question:)
        new(user, entity).public_send(policy_question)
      end

      def initialize(user, entity, permission_query_service: nil)
        @user = user
        @entity = entity
        @permission_query_service = permission_query_service || default_permission_query_service
      end
      attr_reader :user, :entity, :permission_query_service
      private :user, :entity, :permission_query_service

      private

      def default_permission_query_service
        lambda do |options|
          # TODO: Extract this method into a permissions object
          Models::Permission.
            where(user: options.fetch(:user), subject: options.fetch(:subject), role: options.fetch(:roles)).any?
        end
      end
    end
  end
end
