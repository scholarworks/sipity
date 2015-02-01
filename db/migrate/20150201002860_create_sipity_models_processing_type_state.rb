class CreateSipityModelsProcessingTypeState < ActiveRecord::Migration
  def change
    create_table :processing_type_state do |t|
      t.integer :processing_type_id, null: false
      t.string :state, null: false

      t.timestamps null: false
    end

    add_index :processing_type_state, [:processing_type_id, :state],
      unique: true, name: :processing_type_state_aggregate
  end
end
