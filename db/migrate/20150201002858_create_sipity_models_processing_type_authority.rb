class CreateSipityModelsProcessingTypeAuthority < ActiveRecord::Migration
  def change
    create_table :sipity_processing_strategy_authorities do |t|
      t.integer :actor_id, null: false
      t.integer :strategy_role_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_authorities, [:actor_id, :strategy_role_id],
      unique: true, name: :sipity_processing_strategy_authorities_aggregate
  end
end
