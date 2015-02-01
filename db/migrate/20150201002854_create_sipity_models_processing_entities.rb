class CreateSipityModelsProcessingEntities < ActiveRecord::Migration
  def change
    create_table :sipity_processing_entities do |t|
      t.integer :proxy_for_id, null: false
      t.string :proxy_for_type, null: false
      t.integer :processing_type_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entities, [:proxy_for_id, :proxy_for_type], unique: true,
      name: :sipity_processing_entities_proxy_for
    add_index :sipity_processing_entities, :processing_type_id, unique: true
  end
end
