class CreateSipityModelsProcessingEntityEventRegister < ActiveRecord::Migration
  def change
    create_table :sipity_processing_entity_nevent_registers do |t|
      t.integer :strategy_nevent_id, null: false
      t.integer :entity_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entity_nevent_registers, [:strategy_nevent_id, :entity_id],
      name: :sipity_processing_entity_nevent_registers_aggregate
  end
end
