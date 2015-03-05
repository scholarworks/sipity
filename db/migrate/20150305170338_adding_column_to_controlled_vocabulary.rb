class AddingColumnToControlledVocabulary < ActiveRecord::Migration
  def change
    add_column :sipity_simple_controlled_vocabularies, :predicate_value_code, :text
    add_index :sipity_simple_controlled_vocabularies, :predicate_value_code, name: 'sipity_simple_controlled_vocabularies_predicate_code'
  end
end
