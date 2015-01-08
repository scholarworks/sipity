class CreateSipityModelsActorForPermissionAssignments < ActiveRecord::Migration
  def change
    create_table :sipity_actor_for_permission_assignments do |t|
      t.integer :actor_id, index: true
      t.string :actor_type, index: true
      t.string :acting_as, index: true
      t.string :work_type

      t.timestamps null: false
    end

    add_index(
      :sipity_actor_for_permission_assignments,
      [:actor_id, :actor_type, :acting_as, :work_type],
      name: :sipity_actor_for_permission_assignments_composite,
      unique: true
    )
    add_index(
      :sipity_actor_for_permission_assignments,
      [:acting_as, :work_type],
      name: :sipity_actor_for_permission_assignments_by_acting_as_work_type
    )

    change_column_null :sipity_actor_for_permission_assignments, :actor_id, false
    change_column_null :sipity_actor_for_permission_assignments, :actor_type, false
    change_column_null :sipity_actor_for_permission_assignments, :work_type, false
    change_column_null :sipity_actor_for_permission_assignments, :acting_as, false
  end
end
