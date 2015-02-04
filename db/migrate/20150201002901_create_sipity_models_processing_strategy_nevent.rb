class CreateSipityModelsProcessingStrategyNevent < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_nevents do |t|
      t.integer :strategy_id, null: false
      t.integer :resulting_strategy_state_id
      t.string :name, null: false
      t.string :form_class_name
      t.boolean :completion_required, default: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_nevents, [:strategy_id, :name],
      unique: true, name: :sipity_processing_strategy_nevents_aggregate
    add_index :sipity_processing_strategy_nevents, :resulting_strategy_state_id,
      name: :sipity_processing_strategy_nevents_resulting_strategy_state

  end
end
