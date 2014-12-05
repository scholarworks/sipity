class AddIndicesToSipityAdditionalAttributes < ActiveRecord::Migration
  def change
    add_index :sipity_additional_attributes, :sipity_header_id
    add_index :sipity_additional_attributes, [:sipity_header_id, :key]
  end
end
