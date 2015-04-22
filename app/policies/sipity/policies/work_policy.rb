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
          self.user = user
          self.scope = scope
          self.repository = options.fetch(:repository) { default_repository }
        end

        def resolve(options = {})
          repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
            user: user,
            proxy_for_type: scope, filter: { processing_state: options[:processing_state] }
          )
        end

        private

        attr_accessor :user, :scope, :repository

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
