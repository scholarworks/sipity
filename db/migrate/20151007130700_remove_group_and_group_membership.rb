class RemoveGroupAndGroupMembership < ActiveRecord::Migration
  def change
    drop_table :sipity_groups
    drop_table :sipity_group_memberships
  end
end
