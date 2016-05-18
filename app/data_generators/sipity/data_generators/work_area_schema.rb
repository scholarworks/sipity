require 'dry/validation/schema'
require 'sipity/data_generators/strategy_permission_schema'
require 'sipity/data_generators/processing_action_schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work areas.
    WorkAreaSchema = Dry::Validation.Schema do
      key(:work_areas).each do
        key(:attributes).schema do
          key(:name).required(:str?)
          key(:slug).required(:str?)
        end
        key(:actions).each { schema(ProcessingActionSchema) }
        optional(:strategy_permissions).each { schema(StrategyPermissionSchema) }
        optional(:submission_window_config_paths).required { str? | array? { each { str? } } }
      end
    end
  end
end
