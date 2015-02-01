class CreateSipityModelsProcessingTypeAction < ActiveRecord::Migration
  def change
    create_table :processing_type_actions do |t|
      t.integer :processing_type_id, null: false
      t.string :action_name, null: false

      t.timestamps null: false
    end

    add_index :processing_type_actions, [:processing_type_id, :action_name],
      unique: true, name: :processing_type_actions_aggregate
  end
end
