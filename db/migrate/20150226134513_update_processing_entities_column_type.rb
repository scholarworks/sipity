class UpdateProcessingEntitiesColumnType < ActiveRecord::Migration
  def change
    change_column(:sipity_processing_entities, :strategy_state_id, :integer)
  end
end
