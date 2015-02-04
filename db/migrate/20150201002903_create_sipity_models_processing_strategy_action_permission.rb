class CreateSipityModelsProcessingStrategyStateActionPermission < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_action_permissions do |t|
      t.integer :strategy_role_id, null: false
      t.integer :strategy_action_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_action_permissions, [:strategy_role_id, :strategy_action_id],
      unique: true, name: :sipity_processing_strategy_action_permissions_aggregate
  end
end
