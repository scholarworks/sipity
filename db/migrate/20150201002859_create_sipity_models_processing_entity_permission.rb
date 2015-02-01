class CreateSipityModelsProcessingEntityPermission < ActiveRecord::Migration
  def change
    create_table :sipity_processing_entity_permissions do |t|
      t.integer :processing_type_authority_id, null: false
      t.integer :processing_entity_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entity_permissions, [:processing_type_authority_id, :processing_entity_id],
      unique: true, name: :sipity_processing_entity_permissions_aggregate
  end
end
