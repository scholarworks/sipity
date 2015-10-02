class RemoveDatabaseConstraintForEntityRegister < ActiveRecord::Migration
  def change
    change_column_null :sipity_processing_entity_action_registers, :requested_by_actor_id, true
    change_column_null :sipity_processing_entity_action_registers, :on_behalf_of_actor_id, true
    change_column_null :sipity_processing_comments, :actor_id, true
  end
end
