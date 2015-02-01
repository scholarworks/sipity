class CreateSipityModelsProcessingEntityEventRegister < ActiveRecord::Migration
  def change
    create_table :sipity_processing_entity_event_registers do |t|
      t.integer :processing_type_event_id, null: false
      t.integer :processing_entity_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entity_event_registers, [:processing_type_event_id, :processing_entity_id],
      unique: true, name: :sipity_processing_entity_event_registers_aggregate
  end
end
