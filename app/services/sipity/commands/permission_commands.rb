module Sipity
  # :nodoc:
  module Commands
    # Commands related to the permission model
    module PermissionCommands
      module_function

      def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
        role = Models::Permission::CREATING_USER
        actors = [user, group, actor]
        grant_permission_for!(entity: entity, actors: actors, role: role)
      end
      public :grant_creating_user_permission_for!

      def grant_permission_for!(entity:, actors:, role:)
        Array.wrap(actors).flatten.compact.each { |an_actor| Models::Permission.create!(entity: entity, actor: an_actor, role: role) }
      end
      private :grant_permission_for!
      private_class_method :grant_permission_for!
    end
    private_constant :PermissionCommands
  end
end
