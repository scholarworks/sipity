class CreateSipityModelsProcessingStrategyActionPrerequisites < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_action_prerequisites do |t|
      t.integer :guarded_strategy_action_id
      t.integer :prequisite_strategy_action_id

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_action_prerequisites, [:guarded_strategy_action_id, :prequisite_strategy_action_id],
      unique: true, name: :sipity_processing_strategy_action_prerequisites_aggregate
  end
end