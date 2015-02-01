class CreateSipityModelsProcessingTypeState < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_states do |t|
      t.integer :strategy_id, null: false
      t.string :state_name, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_states, [:strategy_id, :state_name],
      unique: true, name: :sipity_processing_type_state_aggregate
  end
end
