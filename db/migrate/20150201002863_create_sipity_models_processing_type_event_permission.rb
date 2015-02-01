class CreateSipityModelsProcessingTypeEventPermission < ActiveRecord::Migration
  def change
    create_table :processing_type_event_permissions do |t|
      t.integer :processing_type_role_id, null: false
      t.integer :processing_type_event_id, null: false

      t.timestamps null: false
    end

    add_index :processing_type_event_permissions, [:processing_type_role_id, :processing_type_event_id],
      unique: true, name: :processing_type_event_permissions_aggregate
  end
end
