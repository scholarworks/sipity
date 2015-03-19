class AddCommentIndex < ActiveRecord::Migration
  def change
    add_index :sipity_processing_comments, :created_at
  end
end
