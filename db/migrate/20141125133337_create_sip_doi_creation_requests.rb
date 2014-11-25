class CreateSipDoiCreationRequests < ActiveRecord::Migration
  def change
    create_table :sip_doi_creation_requests do |t|
      t.integer :sip_header_id, null: false, unique: true
      t.string :state, null: false, length: 16
      t.string :response_message, :text
      t.timestamps
    end

    add_index :sip_doi_creation_requests, :state
  end
end
