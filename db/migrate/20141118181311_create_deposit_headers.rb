class CreateDepositHeaders < ActiveRecord::Migration
  def change
    create_table :deposit_headers do |t|
      t.integer :deposit_request_id
      t.string :title
      t.text :abstract

      t.timestamps
    end
    add_index :deposit_headers, :deposit_request_id, unique: true
    change_column_null :deposit_headers, :deposit_request_id, false
  end
end
