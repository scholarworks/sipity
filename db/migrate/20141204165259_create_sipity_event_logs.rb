class CreateSipityEventLogs < ActiveRecord::Migration
  def change
    create_table :sip_event_logs do |t|
      t.integer :user_id, index: true
      t.integer :subject_id
      t.string :subject_type, limit: 64
      t.string :event_name, index: true

      t.timestamps
    end

    add_index :sip_event_logs, [:user_id, :subject_id, :subject_type], name: :sip_event_logs_user_subject
    add_index :sip_event_logs, [:subject_id, :subject_type, :event_name], name: :sip_event_logs_subject_event_name
    add_index :sip_event_logs, [:subject_id, :subject_type], name: :sip_event_logs_subject
    add_index :sip_event_logs, [:user_id, :event_name], name: :sip_event_logs_user_event_name

    change_column_null :sip_event_logs, :user_id, false
    change_column_null :sip_event_logs, :subject_id, false
    change_column_null :sip_event_logs, :subject_type, false
    change_column_null :sip_event_logs, :event_name, false
  end
end
