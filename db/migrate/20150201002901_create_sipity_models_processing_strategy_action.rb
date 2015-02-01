class CreateSipityModelsProcessingStrategyAction < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_actions do |t|
      t.integer :strategy_id, null: false
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_actions, [:strategy_id, :name],
      unique: true, name: :sipity_processing_strategy_actions_aggregate
  end
end
