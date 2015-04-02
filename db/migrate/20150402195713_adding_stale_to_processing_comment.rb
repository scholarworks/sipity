class AddingStaleToProcessingComment < ActiveRecord::Migration
  def change
    add_column 'sipity_processing_comments', 'stale', :boolean, default: false, index: true
  end
end
