class MigrateActorToIdentifier < ActiveRecord::Migration
  def self.up
    require 'cogitate/models/identifier'
    Sipity::Models::EventLog.find_each do |event_log|
      if event_log.requested_by_type.to_s == 'User'
        encoded_id = Cogitate::Models::Identifier.new(identifying_value: event_log.requested_by.username, strategy: 'netid').id
        event_log.update_columns(identifier_id: encoded_id)
      else
        fail "Expecting #{event_log} to be modified by a user"
      end
    end
    Sipity::Models::Processing::Comment.find_each do |comment|
      comment.update_columns(identifier_id: comment.actor.identifier_id)
    end

    Sipity::Models::Processing::EntityActionRegister.find_each do |register|
      register.update_columns(
        requested_by_identifier_id: register.requested_by_actor.identifier_id,
        on_behalf_of_identifier_id: register.on_behalf_of_actor.identifier_id
      )
    end

    Sipity::Models::Processing::EntitySpecificResponsibility.find_each do |responsibility|
      responsibility.update_columns(identifier_id: responsibility.actor.identifier_id)
    end

    Sipity::Models::Processing::StrategyResponsibility.find_each do |responsibility|
      responsibility.update_columns(identifier_id: responsibility.actor.identifier_id)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
