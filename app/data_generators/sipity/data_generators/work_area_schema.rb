module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work areas.
    class WorkAreaSchema < Dry::Validation::Schema
      key(:work_areas) do |work_areas|
        work_areas.array? do
          work_areas.each do |work_area|
            work_area.hash? do
              work_area.key(:attributes) do |attributes|
                attributes.hash? do
                  attributes.key(:name, &SchemaRulesForProcessingEntity.filled_string)
                  attributes.key(:slug, &SchemaRulesForProcessingEntity.filled_string)
                end
              end
              work_area.key(:actions, &SchemaRulesForProcessingEntity.actions_config)
              work_area.optional(:strategy_permissions, &SchemaRulesForProcessingEntity.strategy_permissions_config)
              work_area.optional(:submission_window_config_paths, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
            end
          end
        end
      end
    end
  end
end
