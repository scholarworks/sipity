require 'dry/validation/schema'
require 'sipity/data_generators/schema_rules_for_processing_entity'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    class SubmissionWindowSchema < Dry::Validation::Schema
      key(:submission_windows) do |submission_windows|
        submission_windows.array? do
          submission_windows.each do |submission_window|
            submission_window.hash? do
              submission_window.key(:attributes) do |attributes|
                attributes.hash? do
                  attributes.key(:slug, &SchemaRulesForProcessingEntity.filled_string)
                  attributes.optional(:open_for_starting_submissions_at) { |value| value.format?(/\A\d{4}-\d{2}-\d{2}\Z/) }
                end
              end
              submission_window.key(:actions, &SchemaRulesForProcessingEntity.actions_config)
              submission_window.optional(:strategy_permissions, &SchemaRulesForProcessingEntity.strategy_permissions_config)
              submission_window.key(:work_type_config_paths, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
            end
          end
        end
      end
    end
  end
end
