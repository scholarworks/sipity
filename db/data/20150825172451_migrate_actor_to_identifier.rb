class MigrateActorToIdentifier < ActiveRecord::Migration
  def self.up
    require 'cogitate/models/identifier'
    Sipity::Models::EventLog.find_each do |event_log|
      next if event_log.identifier_id.present?
      identifier_id = PowerConverter.convert(event_log.requested_by, to: :identifier_id)
      event_log.update_columns(identifier_id: identifier_id)
    end
    Sipity::Models::Processing::Comment.find_each do |comment|
      comment.update_columns(identifier_id: comment.actor.identifier_id)
    end

    Sipity::Models::Processing::EntityActionRegister.find_each do |register|
      next if register.requested_by_identifier_id.present? && register.on_behalf_of_identifier_id.present?
      register.update_columns(
        requested_by_identifier_id: register.requested_by_actor.identifier_id,
        on_behalf_of_identifier_id: register.on_behalf_of_actor.identifier_id
      )
    end

    Sipity::Models::Processing::EntitySpecificResponsibility.find_each do |responsibility|
      next if responsibility.identifier_id.present?
      responsibility.update_columns(identifier_id: responsibility.actor.identifier_id)
    end

    Sipity::Models::Processing::StrategyResponsibility.find_each do |responsibility|
      next if responsibility.identifier_id.present?
      responsibility.update_columns(identifier_id: responsibility.actor.identifier_id)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
