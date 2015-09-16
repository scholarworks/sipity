require 'sipity/policies/processing/processing_entity_policy'
module Sipity
  module Policies
    # Responsible for enforcing access to a given Sipity::Models::WorkArea.
    #
    # This class answers can I take the given action based on the user and
    # the work area.
    #
    # @note This class is on the chopping block; All of the scoping questions
    #   aside from bootstraping a work can be resolved via the processing sub-
    #   system.
    #
    # @see [Pundit gem](http://rubygems.org/gems/pundit) for more on object
    #   oriented authorizaiton.
    class SubmissionWindowPolicy < BasePolicy
      private

      def method_missing(method_name, *)
        Processing::ProcessingEntityPolicy.call(user: user, entity: entity, action_to_authorize: method_name)
      end
    end
  end
end
