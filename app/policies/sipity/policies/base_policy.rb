module Sipity
  module Policies
    # At its core a policy must implement the following API
    #
    # * .call(user:, entity:, policy_authorization_method_name:)
    # * #initialize(user, entity)
    # * #show?
    # * #create?
    # * #update?
    # * #destroy?
    class BasePolicy
      def self.call(user:, entity:, policy_authorization_method_name:)
        new(user, entity).public_send(policy_authorization_method_name)
      end

      def initialize(user, entity, permission_query_service: nil)
        @user = user
        @entity = entity
        @permission_query_service = permission_query_service || defaul_permission_query_service
      end
      attr_reader :user, :entity, :permission_query_service
      private :user, :entity, :permission_query_service

      def show?
        fail NotImplementedError, "Expected #{self.class} to implmenent #show?"
      end

      def create?
        fail NotImplementedError, "Expected #{self.class} to implmenent #create?"
      end

      def update?
        fail NotImplementedError, "Expected #{self.class} to implmenent #update?"
      end

      def destroy?
        fail NotImplementedError, "Expected #{self.class} to implmenent #destroy?"
      end

      private

      def defaul_permission_query_service
        lambda do |options|
          # TODO: Extract this method into a permssions object
          Models::Permission.
            where(user: options.fetch(:user), subject: options.fetch(:subject), role: options.fetch(:roles)).any?
        end
      end
    end
  end
end
