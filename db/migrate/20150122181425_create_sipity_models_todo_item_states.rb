class CreateSipityModelsTodoItemStates < ActiveRecord::Migration
  def change
    create_table :sipity_todo_item_states do |t|
      t.string :entity_id, limit: 32
      t.string :entity_type
      t.string :entity_processing_state
      t.string :enrichment_type
      t.string :enrichment_state

      t.timestamps null: false
    end

    add_index :sipity_todo_item_states, [:entity_id, :entity_type]
    add_index(
      :sipity_todo_item_states,
      [:entity_id, :entity_type, :entity_processing_state, :enrichment_type],
      unique: true, name: :sipity_todo_item_states_key
    )
    change_column_null :sipity_todo_item_states, :entity_id, false
    change_column_null :sipity_todo_item_states, :entity_type, false
    change_column_null :sipity_todo_item_states, :entity_processing_state, false
    change_column_null :sipity_todo_item_states, :enrichment_type, false
    change_column_null :sipity_todo_item_states, :enrichment_state, false
  end
end
