class CreateSipCollaborators < ActiveRecord::Migration
  def change
    create_table :sip_collaborators do |t|
      t.integer :sip_header_id
      t.integer :sequence
      t.string :name
      t.string :role
      t.timestamps
    end

    add_index :sip_collaborators, [:sip_header_id, :sequence]
    change_column_null :sip_collaborators, :sip_header_id, false
  end
end
