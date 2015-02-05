module Sipity
  module Models
    # Responsible for providing the default actors that will be granted
    # permission to an entity based on the request role.
    class ActorForPermissionAssignment < ActiveRecord::Base
      self.table_name = 'sipity_actor_for_permission_assignments'
      belongs_to :actor, polymorphic: true
    end
  end
end
