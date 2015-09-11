class AllowEntitySpecificResponsibilityActorIdToBeNull < ActiveRecord::Migration
  def change
    # With changing towards cogitate I want to instead drive on the identifier_id for entity
    # specific data. This change assumes a sibling data migration
    change_column_null :sipity_processing_entity_specific_responsibilities, :actor_id, true
    change_column_null :sipity_processing_strategy_responsibilities, :actor_id, true
  end
end
