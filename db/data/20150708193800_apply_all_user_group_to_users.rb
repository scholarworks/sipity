class ApplyAllUserGroupToUsers < ActiveRecord::Migration
  def self.up
    #add existing users to that group (unless they are already there)
    User.find_each do |user|
      registered_users_group = Sipity::Models::Group.all_verified_netid_users
      registered_users_group.group_memberships.create(user: user) if registered_users_group.group_memberships.where(user: user).empty?
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
