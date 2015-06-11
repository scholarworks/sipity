class RemoveWorkPublishingStrategy < ActiveRecord::Migration
  def change
    remove_column 'sipity_works', 'work_publication_strategy'
  end
end
