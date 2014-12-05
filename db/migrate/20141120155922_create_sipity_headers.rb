class CreateSipityHeaders < ActiveRecord::Migration
  def change
    create_table :sipity_headers do |t|
      t.string :work_publication_strategy
      t.string :title

      t.timestamps
    end
  end
end
