module Sipity
  # :nodoc:
  module Commands
    # Commands related to the permission model
    #
    # TODO: Need to come up with a better way of handling this. Exposing
    # module functions and instance methods is a bit insane. It works, but
    # increases coupling. Possible solution, module provides a means for
    # delegation to a proper class? The design goal is to provide a way for
    # accessing repository services in other contexts. So the question is:
    # How is that different from module functions and instance methods via
    # mixin? Something to think about.
    module PermissionCommands
      def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
        # REVIEW: Does the constant even make sense on the data structure? Or
        #   is it more relevant here?
        acting_as = Models::Permission::CREATING_USER
        actors = [user, group, actor]
        grant_permission_for!(entity: entity, actors: actors, acting_as: acting_as)
      end

      def grant_permission_for!(entity:, actors:, acting_as:)
        Array.wrap(actors).flatten.compact.each do |an_actor|
          grant_deprecated_permission_for!(entity: entity, actor: an_actor, acting_as: acting_as)
          grant_processing_permission_for!(entity: entity, actor: an_actor, role: acting_as)
        end
      end
      module_function :grant_permission_for!
      public :grant_permission_for!

      def grant_processing_permission_for!(entity:, actor:, role:)
        Services::GrantProcessingPermission.call(entity: entity, actor: actor, role: role)
      end
      module_function :grant_processing_permission_for!
      public :grant_processing_permission_for!

      def grant_deprecated_permission_for!(entity:, actor:, acting_as:)
        Models::Permission.create!(entity: entity, actor: actor, acting_as: acting_as)
      end
      module_function :grant_deprecated_permission_for!
      class << self
        deprecate :grant_deprecated_permission_for!
      end
      private :grant_deprecated_permission_for!
      deprecate :grant_deprecated_permission_for!
    end
  end
end
