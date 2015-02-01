class CreateSipityModelsProcessingActors < ActiveRecord::Migration
  def change
    create_table :sipity_processing_actors do |t|
      t.integer :proxy_for_id, null: false
      t.string :proxy_for_strategy, null: false
      t.string :name_of_proxy

      t.timestamps null: false
    end

    add_index :sipity_processing_actors, [:proxy_for_id, :proxy_for_strategy], unique: true,
      name: :sipity_processing_actors_proxy_for
  end
end
