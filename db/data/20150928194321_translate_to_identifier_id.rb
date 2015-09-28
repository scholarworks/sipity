class TranslateToIdentifierId < ActiveRecord::Migration
  def self.up
    Sipity::Models::Collaborator.where(strategy: nil).find_each do |collaborator|
      collaborator.save!
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
