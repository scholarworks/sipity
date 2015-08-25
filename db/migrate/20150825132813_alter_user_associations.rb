class AlterUserAssociations < ActiveRecord::Migration
  def change
    drop_table :sipity_account_placeholders
    drop_table :sipity_doi_creation_requests

    change_column :sipity_event_logs, :user_id, :string
    change_column :sipity_event_logs, :requested_by_id, :string
    change_column :sipity_group_memberships, :user_id, :string
    change_column :sipity_group_memberships, :group_id, :string
    change_column :sipity_processing_actors, :proxy_for_id, :string
  end
end
