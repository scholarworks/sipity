class CreateSipityModelsNotificationEmails < ActiveRecord::Migration
  def change
    create_table :sipity_notification_emails do |t|
      t.string :method_name, null: false, index: true, unique: true
      t.timestamps null: false
    end
  end
end
