module Sipity
  module DataGenerators
    # Codifies what it takes to "bootstrap" a bare-bones work area.
    #
    # My rationale for this is that the creation of a WorkArea sits outside of
    # the permissioning/processing system. In other words, a system
    # administrator (data super user) is needed to create a WorkArea.
    #
    # As an added benefit, this service is the equivalent of a FactoryGirl
    # factory; But something under proper test.
    class FindOrCreateWorkArea
      def self.call(**keywords, &block)
        new(**keywords).call(&block)
      end

      def initialize(name:, slug:, **keywords)
        partial_suffix = keywords.fetch(:partial_suffix, slug)
        demodulized_class_prefix_name = keywords.fetch(:demodulized_class_prefix_name, slug)
        self.work_area_managers = keywords.fetch(:work_area_managers, [])
        self.work_area = find_or_create_work_area(
          name: name, slug: slug, partial_suffix: partial_suffix, demodulized_class_prefix_name: demodulized_class_prefix_name
        )
      end

      def call
        create_processing_strategy!
        create_work_area_processing_entity!
        associate_work_area_with_processing_strategy!
        generate_general_work_area_permissions!
        call_work_area_specific_data_generator!
        yield(work_area) if block_given?
        work_area
      end

      attr_reader :work_area

      private

      attr_writer :work_area
      attr_accessor :work_area_managers
      attr_reader :processing_strategy, :strategy_role

      def find_or_create_work_area(attributes)
        # Going with slug because these are "more permanent"
        Models::WorkArea.find_by(attributes.slice(:slug)) || Models::WorkArea.create!(attributes)
      end

      def create_work_area_processing_entity!
        work_area.processing_entity || work_area.create_processing_entity!(
          strategy: processing_strategy, strategy_state: processing_strategy.initial_strategy_state
        )
      end

      def associate_work_area_with_processing_strategy!
        Models::Processing::StrategyUsage.find_or_create_by!(strategy: processing_strategy, usage: work_area)
      end

      def create_processing_strategy!
        @processing_strategy ||= Models::Processing::Strategy.find_or_create_by!(name: "#{work_area.class} processing")
      end

      PERMITTED_WORK_MANAGER_ACTIONS = ['show', 'create_submission_window'].freeze
      def generate_general_work_area_permissions!
        PermissionGenerator.call(
          actors: work_area_managers,
          roles: Models::Role::WORK_AREA_MANAGER,
          action_names: PERMITTED_WORK_MANAGER_ACTIONS,
          entity: work_area,
          strategy: processing_strategy,
          strategy_state: processing_strategy.initial_strategy_state
        )
      end

      def call_work_area_specific_data_generator!
        work_area_specific_generator.call(work_area: work_area, processing_strategy: processing_strategy)
      end

      def work_area_specific_generator
        "Sipity::DataGenerators::#{work_area.demodulized_class_prefix_name}::WorkAreaProcessingGenerator".constantize
      rescue NameError
        # Return a null generator
        ->(**_) {}
      end
    end
  end
end
