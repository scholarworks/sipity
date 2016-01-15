require 'dry/validation/schema'
require 'sipity/data_generators/schema_rules_for_processing_entity'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    class WorkTypeSchema < Dry::Validation::Schema
      key(:work_types) do |work_types|
        work_types.array? do
          work_types.each do |work_type|
            work_type.hash? do
              work_type.key(:name, &SchemaRulesForProcessingEntity.filled_string)
              work_type.key(:actions, &SchemaRulesForProcessingEntity.actions_config)
              work_type.optional(:strategy_permissions, &SchemaRulesForProcessingEntity.strategy_permissions_config)
              work_type.optional(:action_analogues) do |analogues|
                analogues.array? do
                  analogues.each do |analogue|
                    analogue.hash? do
                      analogue.key(:action, &SchemaRulesForProcessingEntity.filled_string)
                      analogue.key(:analogous_to, &SchemaRulesForProcessingEntity.filled_string)
                    end
                  end
                end
              end
              work_type.optional(:state_emails) do |processing_hooks|
                processing_hooks.array? do
                  processing_hooks.each do |processing_hook|
                    processing_hook.hash? do
                      processing_hook.key(:state, &SchemaRulesForProcessingEntity.filled_string)
                      processing_hook.key(:emails, &SchemaRulesForProcessingEntity.email_config)
                      processing_hook.key(:reason) do |reason|
                        reason.inclusion?([
                          Parameters::NotificationContextParameter::REASON_ENTERED_STATE,
                          Parameters::NotificationContextParameter::REASON_PROCESSING_HOOK_TRIGGERED
                        ])
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
