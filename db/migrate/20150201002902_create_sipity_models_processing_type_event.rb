class CreateSipityModelsProcessingTypeEvent < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_events do |t|
      t.integer :state_id, null: false
      t.integer :action_id, null: false
      t.string :event_form_class_name, null: false
      t.boolean :completion_required, default: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_events, [:processing_type_state_id, :processing_type_action_id],
      unique: true, name: :sipity_processing_strategy_events_aggregate
  end
end
