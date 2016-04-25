class AddingApiKeyToGroup < ActiveRecord::Migration
  def change
    add_column :sipity_groups, :api_key, :string
    add_index :sipity_groups, [:name, :api_key]
  end
end
