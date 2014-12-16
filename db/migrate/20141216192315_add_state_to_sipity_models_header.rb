class AddStateToSipityModelsHeader < ActiveRecord::Migration
  def change
    add_column :sipity_headers, :processing_state, :string, default: :new, limit: 64
    add_index :sipity_headers, :processing_state
    change_column_null :sipity_headers, :processing_state, false
  end
end
