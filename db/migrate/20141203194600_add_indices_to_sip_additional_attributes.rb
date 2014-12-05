class AddIndicesToSipityAdditionalAttributes < ActiveRecord::Migration
  def change
    add_index :sip_additional_attributes, :sip_header_id
    add_index :sip_additional_attributes, [:sip_header_id, :key]
  end
end
