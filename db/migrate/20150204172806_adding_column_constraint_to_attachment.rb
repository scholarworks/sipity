class AddingColumnConstraintToAttachment < ActiveRecord::Migration
  def change
    change_column_null :sipity_attachments, :pid, false
  end
end
