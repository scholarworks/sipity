module Sipity
  module DataGenerators
    # These are shared rules for processing entities. A change to these rules
    # is a change to the Schemas that have been made.
    #
    # @see dry-validation https://github.com/dryrb/dry-validation
    module SchemaRulesForProcessingEntity
      def self.filled_string
        proc { |value| value.str? & value.filled? }
      end

      def self.string_or_array_of_strings_config
        proc { |receiver| receiver.str? | receiver.array? { receiver.each { |a_receiver| a_receiver.str? } } }
      end

      def self.email_config
        proc do |states|
          states.array? do
            states.each do |state|
              state.hash? do
                state.key(:name) { |name| name.str? }
                state.key(:to, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
                state.optional(:cc, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
                state.optional(:bcc, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
              end
            end
          end
        end
      end

      def self.strategy_permissions_config
        proc do |strategy_permissions|
          strategy_permissions.array? do
            strategy_permissions.each do |strategy_permission|
              strategy_permission.hash? do
                strategy_permission.key(:group, &SchemaRulesForProcessingEntity.filled_string)
                strategy_permission.key(:role, &SchemaRulesForProcessingEntity.filled_string)
              end
            end
          end
        end
      end

      def self.actions_config
        proc do |actions|
          actions.array? do
            actions.each do |action|
              action.hash? do
                action.key(:name, &SchemaRulesForProcessingEntity.filled_string)
                action.optional(:transition_to, &SchemaRulesForProcessingEntity.filled_string)
                action.optional(:required_actions, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
                action.optional(:from_states) do |states|
                  states.array? do
                    states.each do |state|
                      state.hash? do
                        state.key(:name, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
                        state.key(:roles, &SchemaRulesForProcessingEntity.string_or_array_of_strings_config)
                      end
                    end
                  end
                end
                action.optional(:emails, &SchemaRulesForProcessingEntity.email_config)
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
      end
    end
  end
end
