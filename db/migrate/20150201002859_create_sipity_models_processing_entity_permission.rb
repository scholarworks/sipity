class CreateSipityModelsProcessingEntityPermission < ActiveRecord::Migration
  def change
    create_table :sipity_processing_entity_permissions do |t|
      t.integer :strategy_authority_id, null: false
      t.integer :entity_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entity_permissions, [:strategy_authority_id, :entity_id],
      unique: true, name: :sipity_processing_entity_permissions_aggregate
  end
end
