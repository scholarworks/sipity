class CreateSipityModelsProcessingStrategyEventPrerequisites < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_event_prerequisites do |t|
      t.integer :guarded_strategy_event_id
      t.integer :prerequisite_strategy_event_id
      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_event_prerequisites, [:guarded_strategy_event_id, :prerequisite_strategy_event_id],
      unique: true, name: :sipity_processing_strategy_event_prerequisites_aggregate
  end
end