require 'sipity/policies/processing/processing_entity_policy'
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
      define_action_to_authorize :create? do
        return false unless user.present?
        return false if entity.persisted?
        true
      end

      private

      def method_missing(method_name, *)
        Processing::ProcessingEntityPolicy.call(user: user, entity: entity, action_to_authorize: method_name)
      end
    end
  end
end
