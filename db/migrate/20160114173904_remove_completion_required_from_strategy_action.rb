class RemoveCompletionRequiredFromStrategyAction < ActiveRecord::Migration
  def change
    remove_column "sipity_processing_strategy_actions", "completion_required"
    remove_column "sipity_processing_strategy_actions", "form_class_name"
  end
end
