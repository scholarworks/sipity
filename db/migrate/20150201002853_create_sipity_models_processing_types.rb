class CreateSipityModelsProcessingTypes < ActiveRecord::Migration
  def change
    create_table :sipity_processing_types do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :sipity_processing_types, :name, unique: true
  end
end
