class MigrateGroupNames < ActiveRecord::Migration
  def self.up
    name_map = {
      'Graduate School Reviewers' => 'Graduate School ETD Reviewers',
      'All Registered Users' => 'All Verified "netid" Users'
    }
    Sipity::Models::Group.find_each do |group|
      group.update_columns(name: name_map.fetch(group.name, group.name))
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
