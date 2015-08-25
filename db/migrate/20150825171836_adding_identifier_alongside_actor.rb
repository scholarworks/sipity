class AddingIdentifierAlongsideActor < ActiveRecord::Migration
  def change
    add_column :sipity_event_logs, :identifier_id, :string
    add_index "sipity_event_logs", ["identifier_id", "created_at"], name: "index_sipity_event_logs_on_identifier_id_and_created_at"
    add_index "sipity_event_logs", ["identifier_id", "entity_id", "entity_type"], name: "sipity_event_logs_identifier_subject"
    add_index "sipity_event_logs", ["identifier_id", "event_name"], name: "sipity_event_logs_identifier_event_name"
    add_index "sipity_event_logs", ["identifier_id"], name: "index_sipity_event_logs_on_identifier_id"

    add_column :sipity_processing_actors, :identifier_id, :string
    add_index "sipity_processing_actors", ["identifier_id"], name: "sipity_processing_actors_identifier", unique: true

    # TODO: Will need to add non-nil behavior to this
    add_column :sipity_processing_comments, :identifier_id, :string
    add_index :sipity_processing_comments, :identifier_id, name: "index_sipity_processing_comments_on_identifier"

    add_column :sipity_processing_entity_action_registers, :requested_by_identifier_id, :string
    add_column :sipity_processing_entity_action_registers, :on_behalf_of_identifier_id, :string
    add_index :sipity_processing_entity_action_registers, ["strategy_action_id", "entity_id", "on_behalf_of_identifier_id"], name: "sipity_processing_entity_action_registers_on_behalf_id"
    add_index :sipity_processing_entity_action_registers, ["strategy_action_id", "entity_id", "requested_by_identifier_id"], name: "sipity_processing_entity_action_registers_requested_id"

    add_column :sipity_processing_entity_specific_responsibilities, :identifier_id, :string
    add_index "sipity_processing_entity_specific_responsibilities", ["identifier_id"], name: "sipity_processing_entity_specific_responsibilities_identifier"

    add_column :sipity_processing_strategy_responsibilities, :identifier_id, :string
    add_index "sipity_processing_strategy_responsibilities", ["identifier_id", "strategy_role_id"], name: "sipity_processing_strategy_responsibilities_identifier_aggregate", unique: true
  end
end
