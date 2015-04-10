class ExpandingWorkTitleToText < ActiveRecord::Migration
  def change
    change_column 'sipity_works', 'title', 'text'
  end
end
