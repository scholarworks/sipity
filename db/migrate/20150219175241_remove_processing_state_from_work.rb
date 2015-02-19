class RemoveProcessingStateFromWork < ActiveRecord::Migration
  def change
    remove_column :sipity_works, :processing_state
  end
end
