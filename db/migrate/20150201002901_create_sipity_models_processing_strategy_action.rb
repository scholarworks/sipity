class CreateSipityModelsProcessingStrategyAction < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_actions do |t|
      t.integer :strategy_id, null: false
      t.string :action_name, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_actions, [:strategy_id, :action_name],
      unique: true, name: :sipity_processing_strategy_actions_aggregate
  end
end
