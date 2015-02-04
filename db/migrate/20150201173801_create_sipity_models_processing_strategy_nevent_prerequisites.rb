class CreateSipityModelsProcessingStrategyNeventPrerequisites < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_nevent_prerequisites do |t|
      t.integer :guarded_strategy_nevent_id
      t.integer :prerequisite_strategy_nevent_id
      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_nevent_prerequisites, [:guarded_strategy_nevent_id, :prerequisite_strategy_nevent_id],
      unique: true, name: :sipity_processing_strategy_nevent_prerequisites_aggregate
  end
end