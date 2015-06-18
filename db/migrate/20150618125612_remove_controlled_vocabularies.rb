class RemoveControlledVocabularies < ActiveRecord::Migration
  def change
    drop_table :sipity_simple_controlled_vocabularies
  end
end
