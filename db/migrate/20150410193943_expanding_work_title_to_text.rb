class ExpandingWorkTitleToText < ActiveRecord::Migration
  def change
    remove_index 'sipity_works', column: ['title']
    change_column 'sipity_works', 'title', 'text'
    add_index 'sipity_works', 'title', length: { title: 64 }
  end
end
