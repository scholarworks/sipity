class CreateSipityModelsProcessingStrategyEvent < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_events do |t|
      t.integer :originating_strategy_state_id, null: false
      t.integer :strategy_action_id, null: false
      t.integer :resulting_strategy_state_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_events, [:originating_strategy_state_id, :strategy_action_id],
      unique: true, name: :sipity_processing_strategy_events_aggregate

    add_index :sipity_processing_strategy_events, :resulting_strategy_state_id,
      name: :sipity_processing_strategy_events_resulting_state
  end
end
