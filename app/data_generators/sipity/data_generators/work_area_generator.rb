module Sipity
  module DataGenerators
    # Responsible for the generation of a submission window and its corresponding processing entries (i.e. state machine, emails ,etc.)
    class WorkAreaGenerator
      def self.generate_from_json_file(path:, **keywords)
        contents = path.respond_to?(:read) ? path.read : File.read(path)
        data = JSON.parse(contents)
        new(data: data, **keywords).call
      end

      class << self
        alias call  generate_from_json_file
      end

      # @param data [#deep_symbolize_keys] the configuration information from which we will generate all the data entries
      # @param schema [#call] The schema in which you will validate the data
      # @param validator [#call] The validation service for the given data and schema
      def initialize(data:, schema: default_schema, validator: default_validator)
        self.data = data
        self.schema = schema
        self.validator = validator
        validate!
      end

      private

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
        WorkAreaSchema.new.method(:call)
      end

      def validate!
        validator.call(data: data, schema: schema)
      end

      public

      def call
        Array.wrap(data.fetch(:work_areas)).each do |configuration|
          find_or_create_from(configuration: configuration)
        end
      end

      def find_or_create_from(configuration:)
        strategy = find_or_create_strategy!
        work_area = find_or_create_work_area(attributes: configuration.fetch(:attributes))
        create_work_area_processing_entity!(strategy: strategy, work_area: work_area)
        associate_work_area_with_processing_strategy!(work_area: work_area, strategy: strategy)

        find_or_create_strategy_permissions!(
          strategy: strategy, strategy_permissions_configuration: configuration.fetch(:strategy_permissions, [])
        )
        generate_state_diagram(strategy: strategy, actions_configuration: configuration.fetch(:actions))
        build_submission_windows_for(work_area: work_area, submission_window_config_paths: configuration.fetch(:submission_window_config_paths))
      end

      extend Forwardable
      def_delegator StrategyPermissionsGenerator, :call, :find_or_create_strategy_permissions!
      def_delegator ProcessingActionsGenerator, :call, :generate_state_diagram

      def build_submission_windows_for(work_area:, submission_window_config_paths:)
        Array.wrap(submission_window_config_paths).each do |path|
          SubmissionWindowGenerator.generate_from_json_file(work_area: work_area, path: Rails.root.join(path))
        end
      end

      def find_or_create_strategy!
        Models::Processing::Strategy.find_or_create_by!(name: "#{Models::WorkArea} processing")
      end

      def find_or_create_work_area(attributes:)
        slug = PowerConverter.convert_to_slug(attributes.fetch(:slug))
        work_area = Models::WorkArea.find_or_initialize_by(slug: slug)
        if work_area.attributes.symbolize_keys.slice(*attributes.keys) == attributes
          work_area.save! unless work_area.persisted?
          return work_area
        else
          work_area.update!(attributes)
          return work_area
        end
      end

      def create_work_area_processing_entity!(work_area:, strategy:)
        work_area.processing_entity || work_area.create_processing_entity!(
          strategy: strategy, strategy_state: strategy.initial_strategy_state
        )
      end

      def associate_work_area_with_processing_strategy!(work_area:, strategy:)
        Models::Processing::StrategyUsage.find_or_create_by!(strategy: strategy, usage: work_area)
      end
    end
  end
end
