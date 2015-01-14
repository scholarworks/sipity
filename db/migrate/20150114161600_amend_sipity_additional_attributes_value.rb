class AmendSipityAdditionalAttributesValue < ActiveRecord::Migration
  def change
    change_column :sipity_additional_attributes, :value, :text
  end
end
