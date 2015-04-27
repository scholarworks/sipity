class RemoveApplicationConcept < ActiveRecord::Migration
  def change
    drop_table :sipity_application_concepts
  end
end
