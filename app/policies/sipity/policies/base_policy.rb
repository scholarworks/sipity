module Sipity
  module Policies
    # At its core a policy must implement the following API
    #
    # * .call(user:, entity:, action_to_authorize:)
    # * #initialize(user, entity)
    class BasePolicy
      # Exposed as a convenience method and the public interface into the Policy
      # subsystem.
      #
      # @param user [User]
      # @param entity [#persisted?]
      # @param action_to_authorize [Symbol] In the general case this will be :show?,
      #   :create?, :update?, or :destroy?; However in other cases that may not
      #   be the correct answer.
      #
      # @return [Boolean] If the user can take the action, then return true.
      #   otherwise return false.
      def self.call(user:, entity:, action_to_authorize:)
        new(user, entity).public_send(action_to_authorize)
      end

      class_attribute :registered_action_to_authorizes, instance_writer: false
      self.registered_action_to_authorizes = Set.new
      private :registered_action_to_authorizes, :registered_action_to_authorizes?

      def self.define_action_to_authorize(method_name, &block)
        self.registered_action_to_authorizes += [method_name]
        define_method(method_name, &block)
      end
      private_class_method :define_action_to_authorize

      def initialize(user, entity)
        self.user = user
        self.entity = entity
      end
      attr_accessor :user, :entity
      private :user, :user=, :entity=, :entity
    end
  end
end
