class CreateSipityModelsNotificationNotifiableContexts < ActiveRecord::Migration
  def change
    create_table :sipity_notification_notifiable_contexts do |t|
      t.integer :notifying_concern_id, null: false
      t.string :notifying_concern_type, null: false
      t.string :reason_for_notification, null: false
      t.integer :email_id, null: false

      t.timestamps null: false
    end
    add_index(
      :sipity_notification_notifiable_contexts,
      [:notifying_concern_id, :notifying_concern_type],
      name: :idx_sipity_notification_notifiable_contexts_concern
    )
    add_index(
      :sipity_notification_notifiable_contexts,
      [:notifying_concern_id, :notifying_concern_type, :reason_for_notification],
      name: :idx_sipity_notification_notifiable_contexts_concern_context
    )
    add_index(
      :sipity_notification_notifiable_contexts,
      [:email_id],
      name: :idx_sipity_notification_notifiable_contexts_email_id
    )
    add_index(
      :sipity_notification_notifiable_contexts,
      [:notifying_concern_id, :notifying_concern_type, :reason_for_notification, :email_id],
      name: :idx_sipity_notification_notifiable_contexts_concern_surrogate,
      unique: true
    )
  end
end
