class CreateDepositSubmissions < ActiveRecord::Migration
  def change
    create_table :deposit_submissions do |t|
      t.integer :deposit_request_id
      t.timestamps
    end
    add_index :deposit_submissions, :deposit_request_id, unique: true
    change_column_null :deposit_submissions, :deposit_request_id, false
  end
end
