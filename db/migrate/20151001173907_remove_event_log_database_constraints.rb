class RemoveEventLogDatabaseConstraints < ActiveRecord::Migration
  def change
    change_column_null "sipity_event_logs", "requested_by_id", true
    change_column_null "sipity_event_logs", "requested_by_type", true
    change_column_null "sipity_event_logs", "user_id", true
  end
end
