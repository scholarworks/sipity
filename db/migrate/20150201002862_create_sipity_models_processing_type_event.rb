class CreateSipityModelsProcessingTypeEvent < ActiveRecord::Migration
  def change
    create_table :processing_type_events do |t|
      t.integer :processing_type_state_id, null: false
      t.integer :processing_type_action_id, null: false
      t.string :event_form_class_name, null: false
      t.boolean :completion_required, default: false

      t.timestamps null: false
    end

    add_index :processing_type_events, [:processing_type_state_id, :processing_type_action_id],
      unique: true, name: :processing_type_events_aggregate
  end
end
