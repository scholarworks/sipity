class CreateSipityCollaborators < ActiveRecord::Migration
  def change
    create_table :sipity_collaborators do |t|
      t.string :work_id, limit: 32
      t.integer :sequence
      t.string :name
      t.string :role
      t.timestamps null: false
    end

    add_index :sipity_collaborators, [:work_id, :sequence]
    change_column_null :sipity_collaborators, :work_id, false
    change_column_null :sipity_collaborators, :role, false
  end
end
