class CreateSipitySips < ActiveRecord::Migration
  def change
    create_table :sipity_sips do |t|
      t.string :work_publication_strategy
      t.string :title

      t.timestamps
    end
  end
end
