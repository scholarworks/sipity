require 'dry/validation/schema'
require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    SubmissionWindowSchema = Dry::Validation.Schema do
      key(:submission_windows).each do
        key(:attributes).schema do
          key(:slug).required(:str?)
          optional(:open_for_starting_submissions_at).required(format?: /\A\d{4}-\d{2}-\d{2}\Z/)
        end
        key(:actions).each { schema(ProcessingActionSchema) }
        optional(:strategy_permissions).each { schema(StrategyPermissionSchema) }
        key(:work_type_config_paths).required { str? | array? { each { str? } } }
      end
    end
  end
end
