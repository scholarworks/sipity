class CreateCollaboratorSpecificResponsibility < ActiveRecord::Migration
  def self.up
    Sipity::Models::Collaborator.where(responsible_for_review: true).find_each do |collaborator|
      next unless collaborator.email.present?
      entity = Sipity::Conversions::ConvertToProcessingEntity(collaborator.work)
      role = Sipity::Models::Role::ADVISING
      Sipity::Services::ProcessingPermissionHandler.grant(role: role, entity: entity, identifiable: collaborator)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
