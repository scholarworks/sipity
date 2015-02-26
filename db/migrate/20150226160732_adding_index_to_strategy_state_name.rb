class AddingIndexToStrategyStateName < ActiveRecord::Migration
  def change
    add_index "sipity_processing_strategy_states", "name"
  end
end
