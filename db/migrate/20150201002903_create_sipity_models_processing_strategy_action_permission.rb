class CreateSipityModelsProcessingStrategyActionPermission < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_event_permissions do |t|
      t.integer :strategy_role_id, null: false
      t.integer :strategy_event_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_event_permissions, [:strategy_role_id, :strategy_event_id],
      unique: true, name: :sipity_processing_strategy_event_permissions_aggregate
  end
end
