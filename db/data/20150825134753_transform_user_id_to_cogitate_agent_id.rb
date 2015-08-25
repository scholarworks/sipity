require 'cogitate/models/identifier'
class TransformUserIdToCogitateAgentId < ActiveRecord::Migration
  def self.up
    Sipity::Models::Processing::Actor.find_each do |actor|
      actor.update_columns(identifier_id: PowerConverter.convert(actor, to: :identifier_id))
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
