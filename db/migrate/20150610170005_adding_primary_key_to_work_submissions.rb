class AddingPrimaryKeyToWorkSubmissions < ActiveRecord::Migration
  def change
    add_column :sipity_work_submissions, :id, :primary_key
  end
end
