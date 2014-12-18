class CreateSipityPermissions < ActiveRecord::Migration
  def change
    create_table :sipity_permissions, id: false do |t|
      t.integer :actor_id, index: true
      t.string :actor_type, index: true, limit: 64
      t.integer :entity_id, index: true
      t.string :entity_type, index: true, limit: 64
      t.string :role, index: true, limit: 32

      t.timestamps
    end
    add_index :sipity_permissions, [:actor_id, :actor_type, :entity_id, :entity_type], name: :sipity_permissions_actor_subject
    add_index :sipity_permissions, [:entity_id, :entity_type, :role], name: :sipity_permissions_entity_role
    add_index :sipity_permissions, [:actor_id, :actor_type, :role], name: :sipity_permissions_actor_role

    change_column_null :sipity_permissions, :actor_id, false
    change_column_null :sipity_permissions, :actor_type, false
    change_column_null :sipity_permissions, :entity_id, false
    change_column_null :sipity_permissions, :entity_type, false
    change_column_null :sipity_permissions, :role, false
  end
end
