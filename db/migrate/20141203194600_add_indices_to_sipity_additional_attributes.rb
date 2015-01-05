class AddIndicesToSipityAdditionalAttributes < ActiveRecord::Migration
  def change
    add_index :sipity_additional_attributes, :sip_id
    add_index :sipity_additional_attributes, [:sip_id, :key]
  end
end
