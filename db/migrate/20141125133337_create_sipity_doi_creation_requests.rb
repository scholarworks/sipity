class CreateSipityDoiCreationRequests < ActiveRecord::Migration
  def change
    create_table :sipity_doi_creation_requests do |t|
      t.string :work_id, limit: 32, null: false, unique: true
      t.string :state, null: false, length: 16
      t.string :response_message, :text
      t.timestamps null: false
    end

    add_index :sipity_doi_creation_requests, :state
  end
end
