class ConvertingActionRegistry < ActiveRecord::Migration
  def self.up
    Sipity::Models::Processing::EntityActionRegister.includes(:entity).where(subject_type: 'Sipity::Models::Work').find_each do |register|
      register.update_column(:subject_id, register.entity.proxy_for_id)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
