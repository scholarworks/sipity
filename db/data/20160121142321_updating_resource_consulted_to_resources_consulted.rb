class UpdatingResourceConsultedToResourcesConsulted < ActiveRecord::Migration
  def self.up
    Sipity::Models::AdditionalAttribute.where(key: 'resource_consulted').update_all(key: 'resources_consulted')
    Sipity::Models::AdditionalAttribute.where(key: 'other_resource_consulted').update_all(key: 'other_resources_consulted')
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
