class CreateSipityPermissions < ActiveRecord::Migration
  def change
    create_table :sipity_permissions do |t|
      t.integer :user_id, index: true
      t.integer :subject_id, index: true
      t.string :subject_type, index: true, limit: 64
      t.string :role, index: true, limit: 32

      t.timestamps
    end
    add_index :sipity_permissions, [:user_id, :subject_id, :subject_type], name: :sipity_permissions_user_subject
    add_index :sipity_permissions, [:subject_id, :subject_type, :role], name: :sipity_permissions_subject_role
    add_index :sipity_permissions, [:user_id, :role], name: :sipity_permissions_user_role

    change_column_null :sipity_permissions, :user_id, false
    change_column_null :sipity_permissions, :subject_id, false
    change_column_null :sipity_permissions, :subject_type, false
    change_column_null :sipity_permissions, :role, false
  end
end
