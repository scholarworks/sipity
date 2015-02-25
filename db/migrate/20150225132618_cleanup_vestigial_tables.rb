class CleanupVestigialTables < ActiveRecord::Migration
  def change
    drop_table :sipity_actor_for_permission_assignments
  end
end
