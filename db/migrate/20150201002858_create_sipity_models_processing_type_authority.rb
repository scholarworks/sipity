class CreateSipityModelsProcessingTypeAuthority < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_authorities do |t|
      t.integer :processing_actor_id, null: false
      t.integer :processing_type_role_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_authorities, [:processing_actor_id, :processing_type_role_id],
      unique: true, name: :sipity_processing_strategy_authorities_aggregate
  end
end
