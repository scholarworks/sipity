module Sipity
  # :nodoc:
  module Commands
    # Commands related to the permission model
    module PermissionCommands
      def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
        role = Models::Permission::CREATING_USER
        actors = [user, group, actor].flatten.compact
        actors.each { |an_actor| Models::Permission.create!(entity: entity, actor: an_actor, role: role) }
      end
      module_function :grant_creating_user_permission_for!
      public :grant_creating_user_permission_for!
    end
    private_constant :PermissionCommands
  end
end
