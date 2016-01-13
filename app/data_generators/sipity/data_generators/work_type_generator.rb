module Sipity
  module DataGenerators
    class WorkTypeGenerator
      def self.call(**keywords)
        new(**keywords).call
      end

      def initialize(submission_window:, data:, validator: default_validator, schema: default_schema)
        self.submission_window = submission_window
        self.data = data
        self.schema = schema
        self.validator = validator
        validate!
      end

      private

      attr_accessor :submission_window

      attr_reader :data

      def data=(input)
        @data = input.deep_symbolize_keys
      end

      attr_accessor :validator

      def default_validator
        SchemaValidator.method(:call)
      end

      attr_accessor :schema

      def default_schema
        WorkTypeSchema.new.method(:call)
      end

      def validate!
        validator.call(data: data, schema: schema)
      end

      public

      def call
        Array.wrap(data.fetch(:work_types)).each do |configuration|
          find_or_create_from(configuration: configuration)
        end
      end

      private

      def find_or_create_from(configuration:)
        work_type = find_or_create_work_type!(work_type: configuration.fetch(:name))
        strategy_usage = find_or_create_strategy_usage!(work_type: work_type)
        strategy = strategy_usage.strategy
        assign_submission_window_work_type(work_type: work_type)
        find_or_create_strategy_permissions!(
          strategy: strategy, strategy_permissions_configuration: configuration.fetch(:strategy_permissions, [])
        )
        generate_state_diagram(strategy: strategy, actions_configuration: configuration.fetch(:actions))
        generate_processing_hooks(strategy: strategy, processing_hooks_configuration: configuration.fetch(:processing_hooks, []))
      end

      def find_or_create_work_type!(work_type:)
        PowerConverter.convert_to_work_type(work_type)
      end

      def find_or_create_strategy_usage!(work_type:)
        return work_type.strategy_usage if work_type.strategy_usage
        # NOTE: Assumption, each work type has one and only one processing strategy
        #   and it does not vary by submission window.
        strategy = Models::Processing::Strategy.find_or_create_by!(name: "#{work_type.name} processing")
        work_type.create_strategy_usage!(strategy: strategy)
      end

      def assign_submission_window_work_type(work_type:)
        Models::SubmissionWindowWorkType.find_or_create_by!(work_type: work_type, submission_window: submission_window)
      end

      def find_or_create_strategy_permissions!(strategy:, strategy_permissions_configuration:)
        Array.wrap(strategy_permissions_configuration).each do |configuration|
          group = Models::Group.find_or_create_by!(name: configuration.fetch(:group))
          PermissionGenerator.call(actors: group, roles: configuration.fetch(:role), strategy: strategy)
        end
      end

      def generate_state_diagram(strategy:, actions_configuration:)
        Array.wrap(actions_configuration).each do |configuration|
          Array.wrap(configuration.fetch(:name)).each do |name|
            DataGenerators::StateMachineGenerator.generate_from_schema(strategy: strategy, name: name, **configuration.except(:name))
          end
        end
      end

      def generate_processing_hooks(strategy:, processing_hooks_configuration:)
        Array.wrap(processing_hooks_configuration).each do |configuration|
          scope = configuration.fetch(:state)
          Array.wrap(configuration.fetch(:emails)).each do |email_configuration|
            email_name = email_configuration.fetch(:name)
            recipients = email_configuration.slice(:to, :cc, :bcc)
            DataGenerators::EmailNotificationGenerator.call(
              strategy: strategy, scope: scope, email_name: email_name, recipients: recipients,
              reason: Parameters::NotificationContextParameter::REASON_PROCESSING_HOOK_TRIGGERED
            )
          end
        end
      end
    end
  end
end
