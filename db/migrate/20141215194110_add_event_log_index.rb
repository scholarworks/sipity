class AddEventLogIndex < ActiveRecord::Migration
  def change
    add_index :sipity_event_logs, :created_at
    add_index :sipity_event_logs, [:user_id, :created_at]
  end
end
