class RenamingCollegeToPrimaryCollege < ActiveRecord::Migration
  def self.up
    Sipity::Models::AdditionalAttribute.where(key: "college").update_all(key: "primary_college")
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
