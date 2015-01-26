class CreateSipityModelsWorkTypeTodoListConfigs < ActiveRecord::Migration
  def change
    create_table :sipity_work_type_todo_list_configs do |t|
      t.string :work_type
      t.string :work_processing_state
      t.string :enrichment_type
      t.string :enrichment_group

      t.timestamps null: false
    end

    add_index(
      :sipity_work_type_todo_list_configs, [:work_type, :work_processing_state, :enrichment_type],
       unique: true, name: :sipity_work_type_todo_list_config_composite_index
    )
    add_index(
      :sipity_work_type_todo_list_configs, [:work_type, :work_processing_state, :enrichment_group],
      name: :sipity_work_type_todo_list_config_completion_index
    )
    change_column_null :sipity_work_type_todo_list_configs, :work_type, false
    change_column_null :sipity_work_type_todo_list_configs, :work_processing_state, false
    change_column_null :sipity_work_type_todo_list_configs, :enrichment_type, false
    change_column_null :sipity_work_type_todo_list_configs, :enrichment_group, false
  end
end
