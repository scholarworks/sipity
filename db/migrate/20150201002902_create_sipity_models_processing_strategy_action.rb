class CreateSipityModelsProcessingStrategyAction < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_actions do |t|
      t.integer :originating_strategy_state_id, null: false
      t.integer :strategy_event_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_actions, [:originating_strategy_state_id, :strategy_event_id],
      unique: true, name: :sipity_processing_strategy_actions_aggregate
  end
end
