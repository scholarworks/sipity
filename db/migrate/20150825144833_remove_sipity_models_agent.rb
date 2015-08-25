class RemoveSipityModelsAgent < ActiveRecord::Migration
  def change
    drop_table :sipity_agents
  end
end
