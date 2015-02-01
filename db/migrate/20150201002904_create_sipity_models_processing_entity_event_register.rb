class CreateSipityModelsProcessingEntityEventRegister < ActiveRecord::Migration
  def change
    create_table :sipity_processing_entity_event_registers do |t|
      t.integer :strategy_event_id, null: false
      t.integer :entity_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entity_event_registers, [:strategy_event_id, :entity_id],
      unique: true, name: :sipity_processing_entity_event_registers_aggregate
  end
end
