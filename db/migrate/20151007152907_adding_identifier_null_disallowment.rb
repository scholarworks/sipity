class AddingIdentifierNullDisallowment < ActiveRecord::Migration
  def change
    change_column_null :sipity_event_logs, :identifier_id, false
    change_column_null :sipity_processing_comments, :identifier_id, false
    change_column_null :sipity_processing_entity_specific_responsibilities, :identifier_id, false
    change_column_null :sipity_processing_strategy_responsibilities, :identifier_id, false
    change_column_null :sipity_processing_entity_action_registers, :requested_by_identifier_id, false
    change_column_null :sipity_processing_entity_action_registers, :on_behalf_of_identifier_id, false
  end
end
