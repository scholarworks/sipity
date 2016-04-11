module Sipity
  module Services
    # A service object to find and enforce appropriate policies.
    #
    # @see Sipity::Policies
    class AuthorizationLayer
      # A quick access method for authorizing access to a file. It is a targeted
      # method that ties directly into serving attachments and the
      # implementation of attachment delivery.
      #
      # @note I am not a fan of methods that representat a negation concept (ie
      #   #not_found?, #without_children) as I have seen them often lead to
      #   double negatives.
      #
      # @see ./config/initializers/dragonfly.rb for usage
      #
      # @see http://markevans.github.io/dragonfly/configuration/
      #   Dragonfly.app.configure { before_serve } to understand interaction.
      #
      # @note This circumvents using repository lookup, and drills down quick
      #   into ActiveRecord queries.
      def self.without_authorization_to_attachment(file_uid:, user:)
        if user.present?
          # HACK: I'd prefer to use an attachment's policy instead of its related
          #   work; But, for now this will need to suffice.
          work = Models::Attachment.includes(:work).find_by!(file_uid: file_uid).work
          return :authorized if Policies.authorized_for?(user: user, entity: work, action_to_authorize: :show?)
        end
        # REVIEW: A short-circuit. A general assumption for sipity is that
        #   attachments are available only to authenticated users.
        yield
      end

      def initialize(context, collaborators = {})
        self.context = context
        self.user = context.current_user
        self.policy_authorizer = collaborators.fetch(:policy_authorizer) { default_policy_authorizer }
      end

      # Responsible for enforcing policies on the :action_to_authorizes_and_entity_pairs.
      #
      # @param action_to_authorizes_and_entity_pairs [Hash<Symbol,Object>, #each] Yield two elements a
      #   :action_to_authorize and an :entity
      #
      # @yield Returns control to the caller if all :action_to_authorizes_and_entity_pairs
      #   are authorized.
      #
      # @raise [Exceptions::AuthorizationFailureError] if one of the
      #   action_to_authorize/entity pairs raise to authorize.
      #
      # @note If the context implements #callbacks, that will be called.
      #
      # @todo Would it be helpful to include in the exception the policy_enforcer
      #   that was found?
      def enforce!(action_to_authorizes_and_entity_pairs = {})
        action_to_authorizes_and_entity_pairs.each do |action_to_authorize, entity|
          next if policy_authorizer.call(user: user, action_to_authorize: action_to_authorize, entity: entity)
          context.callback(:unauthorized) if context.respond_to?(:callback)
          raise Exceptions::AuthorizationFailureError, user: user, action_to_authorize: action_to_authorize, entity: entity
        end
        yield
      end

      private

      attr_accessor :user, :context, :policy_authorizer

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
