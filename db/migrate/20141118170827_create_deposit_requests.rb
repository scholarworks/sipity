class CreateDepositRequests < ActiveRecord::Migration
  def change
    create_table :deposit_requests do |t|
      t.string :publication_response
      t.timestamps
    end
  end
end
