class CleanupVestigialTables < ActiveRecord::Migration
  def change
    drop_table :sipity_actor_for_permission_assignments
    drop_table :sipity_todo_item_states
    drop_table :sipity_work_type_todo_list_configs
  end
end
