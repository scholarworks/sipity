class RemovingDefaultActionType < ActiveRecord::Migration
  def change
    change_column_default :sipity_processing_strategy_actions, :action_type, nil
  end
end
