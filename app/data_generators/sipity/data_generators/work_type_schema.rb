require 'dry/validation/schema'

module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work types.
    class WorkTypeSchema < Dry::Validation::Schema
      filled_string = proc { |value| value.str? & value.filled? }
      string_or_array_of_strings_config = proc { |receiver| receiver.str? | receiver.array? { receiver.each { |a_receiver| a_receiver.str? } } }
      email_config =  proc do |states|
        states.array? do
          states.each do |state|
            state.hash? do
              state.key(:name) { |name| name.str? }
              state.key(:to, &string_or_array_of_strings_config)
              state.optional(:cc, &string_or_array_of_strings_config)
              state.optional(:bcc, &string_or_array_of_strings_config)
            end
          end
        end
      end
      key(:work_types) do |work_types|
        work_types.array? do
          work_types.each do |work_type|
            work_type.hash? do
              work_type.key(:name, &filled_string)
              work_type.key(:actions) do |actions|
                actions.array? do
                  actions.each do |action|
                    action.hash? do
                      action.key(:name, &filled_string)
                      action.optional(:transition_to, &filled_string)
                      action.optional(:required_actions, &string_or_array_of_strings_config)
                      action.optional(:states) do |states|
                        states.array? do
                          states.each do |state|
                            state.hash? do
                              state.key(:name, &string_or_array_of_strings_config)
                              state.key(:roles, &string_or_array_of_strings_config)
                            end
                          end
                        end
                      end
                      action.optional(:emails, &email_config)
                      action.optional(:attributes) do |attributes|
                        attributes.hash? do
                          attributes.optional(:presentation_sequence) { |seq| seq.int? & seq.gteq?(0) }
                          attributes.optional(:allow_repeat_within_current_state, &:bool?)
                        end
                      end
                    end
                  end
                end
              end
              work_type.optional(:strategy_permissions) do |strategy_permissions|
                strategy_permissions.array? do
                  strategy_permissions.each do |strategy_permission|
                    strategy_permission.hash? do
                      strategy_permission.key(:group, &filled_string)
                      strategy_permission.key(:role, &filled_string)
                    end
                  end
                end
              end
              work_type.optional(:action_analogues) do |analogues|
                analogues.array? do
                  analogues.each do |analogue|
                    analogue.hash? do
                      analogue.key(:action, &filled_string)
                      analogue.key(:analogous_to, &filled_string)
                    end
                  end
                end
              end
              work_type.optional(:state_emails) do |processing_hooks|
                processing_hooks.array? do
                  processing_hooks.each do |processing_hook|
                    processing_hook.hash? do
                      processing_hook.key(:state, &filled_string)
                      processing_hook.key(:emails, &email_config)
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
