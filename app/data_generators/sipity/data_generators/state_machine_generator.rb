module Sipity
  module DataGenerators
    class StateMachineGenerator
      def self.generate_from_schema(strategy:, name:, **keywords)
        new(
          processing_strategy: strategy, action_name: name, config: keywords,
          email_generator_method_name: :schema_based_email_generator_method
        ).call
      end

      def self.call(processing_strategy:, action_name:, config:)
        new(
          processing_strategy: processing_strategy, action_name: action_name, config: config,
         email_generator_method_name: :deprecated_email_generator_method
        ).call
      end

      def initialize(processing_strategy:, action_name:, config:, email_generator_method_name: :deprecated_email_generator_method)
        self.processing_strategy = processing_strategy
        self.action_name = action_name
        self.config = config
        self.email_generator_method_name = email_generator_method_name
      end

      private

      attr_accessor :processing_strategy, :action_name, :config, :email_generator_method_name

      def create_the_strategy_action!
        @action = Models::Processing::StrategyAction.find_or_create_by!(strategy: processing_strategy, name: action_name.to_s)
      end

      public

      attr_reader :action

      def call
        create_the_strategy_action!

        if config.key?(:attributes)
          action_attributes = config.fetch(:attributes).stringify_keys
          existing_action_attributes = action.attributes.slice(*action_attributes.keys)
          unless action_attributes == existing_action_attributes
            action.update_attributes!(action_attributes)
          end
        end

        # Strategy State
        config.fetch(:states, {}).each do |state_names, state_config|
          # TODO: Once the schema load method is used tidy this up
          if state_names.is_a?(Hash)
            state_config = state_names.except(:name) if state_config.nil?
            state_names = state_names.fetch(:name)
          end
          Array.wrap(state_names).each do |state_name|
            strategy_state = Models::Processing::StrategyState.find_or_create_by!(strategy: processing_strategy, name: state_name.to_s)
            PermissionGenerator.call(
              actors: [],
              roles: state_config.fetch(:roles),
              strategy_state: strategy_state,
              action_names: action_name,
              strategy: processing_strategy
            )
          end
        end

        # Prerequisites
        if config.key?(:transition_to)
          transition_to_state = Models::Processing::StrategyState.find_or_create_by!(strategy: processing_strategy, name: config.fetch(:transition_to).to_s)
          if action.resulting_strategy_state != transition_to_state
            action.resulting_strategy_state = transition_to_state
            action.action_type = action.default_action_type
            action.save!
          end
        end

        # Required Actions
        if config.key?(:required_actions)
          Array.wrap(config.fetch(:required_actions)).each do |required_action_name|
            prerequisite_action = Models::Processing::StrategyAction.find_or_create_by!(strategy: processing_strategy, name: required_action_name)
            Models::Processing::StrategyActionPrerequisite.find_or_create_by!(guarded_strategy_action: action, prerequisite_strategy_action: prerequisite_action)
          end
        end

        send(email_generator_method_name, processing_strategy: processing_strategy, config: config)
      end

      def deprecated_email_generator_method(processing_strategy:, config:)
        config.fetch(:emails, {}).each do |email_name, recipients|
          EmailNotificationGenerator.call(
            strategy: processing_strategy, email_name: email_name, recipients: recipients, scope: action_name,
            reason: Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN
          )
        end
      end

      def schema_based_email_generator_method(processing_strategy:, config:)
        Array.wrap(config.fetch(:emails, [])).each do |configuration|
          email_name = configuration.fetch(:name)
          recipients = configuration.slice(:to, :cc, :bcc)
          EmailNotificationGenerator.call(
            strategy: processing_strategy, email_name: email_name, recipients: recipients, scope: action_name,
            reason: Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN
          )
        end
      end
    end
  end
end
