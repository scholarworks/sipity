class RemovePermissionsTable < ActiveRecord::Migration
  def change
    drop_table :sipity_permissions
  end
end
