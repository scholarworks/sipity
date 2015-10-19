class CreateSipityWorks < ActiveRecord::Migration
  def change
    create_table :sipity_works, id: false do |t|
      t.string :id, limit: 32
      t.string :work_publication_strategy
      t.string :title

      t.timestamps null: false
    end
    add_index :sipity_works, :id, unique: true
    add_index :sipity_works, :title
    add_index :sipity_works, :work_publication_strategy
    change_column_null :sipity_works, :id, false
  end
end
