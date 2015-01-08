class AddWorkTypeToSip < ActiveRecord::Migration
  def change
    add_column :sipity_sips, :work_type, :string
    add_index :sipity_sips, :work_type
    change_column_null :sipity_sips, :work_type, false
  end
end
