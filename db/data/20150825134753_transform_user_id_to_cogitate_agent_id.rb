require 'cogitate/models/identifier'
class TransformUserIdToCogitateAgentId < ActiveRecord::Migration
  GROUP_MAP = {
    'Graduate School Reviewers' => 'Graduate School ETD Reviewers',
    'All Registered Users' => Cogitate::Models::Identifier.new_for_implicit_verified_group_by_strategy(strategy: 'netid').identifying_value
  }
  def self.up
    Sipity::Models::Processing::Actor.find_each do |actor|
      case actor.proxy_for
      when User
        encoded_id = Cogitate::Models::Identifier.new(strategy: 'netid', identifying_value: actor.proxy_for.username).id
      when Sipity::Models::Group
        encoded_id = Cogitate::Models::Identifier.new(strategy: 'group', identifying_value: GROUP_MAP.fetch(actor.proxy_for.name, actor.proxy_for.name)).id
      when Sipity::Models::Collaborator
        if actor.proxy_for.email.present?
          encoded_id = Cogitate::Models::Identifier.new(strategy: 'email', identifying_value: actor.proxy_for.email).id
        else
          raise "Expected #{actor.proxy_for} to have an email (not a NetID)"
        end
      end
      actor.identifier_id = encoded_id
      actor.save!
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
