class CreateSipityModelsAttachments < ActiveRecord::Migration
  def change
    create_table :sipity_attachments, id: false do |t|
      t.integer :sip_id
      t.string :pid
      t.string :predicate_name
      t.string :file_uid
      t.string :file_name

      t.timestamps null: false
    end

    add_index :sipity_attachments, :sip_id
    add_index :sipity_attachments, :pid, unique: true
    change_column_null :sipity_attachments, :sip_id, false
    change_column_null :sipity_attachments, :predicate_name, false
    change_column_null :sipity_attachments, :file_uid, false
    change_column_null :sipity_attachments, :file_name, false
  end
end
