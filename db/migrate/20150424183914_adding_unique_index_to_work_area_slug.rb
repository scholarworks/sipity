class AddingUniqueIndexToWorkAreaSlug < ActiveRecord::Migration
  def change
    add_column 'sipity_work_areas', 'name', 'string', null: false
    add_index 'sipity_work_areas', 'name', unique: true
    add_index 'sipity_work_areas', 'slug', unique: true
    add_index 'sipity_application_concepts', 'slug', unique: true
  end
end
