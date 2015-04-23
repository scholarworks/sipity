module Sipity
  module Services
    # Codifies what it takes to "bootstrap" a bare-bones work area.
    #
    # My rationale for this is that the creation of a WorkArea sits outside of
    # the permissioning/processing system. In other words, a system
    # administrator (data super user) is needed to create a WorkArea.
    #
    # As an added benefit, this service is the equivalent of a FactoryGirl
    # factory; But something under proper test.
    class CreateWorkAreaService
      def self.call(**keywords)
        new(**keywords).call
      end

      def initialize(slug:, **keywords)
        partial_suffix = keywords.fetch(:partial_suffix, slug)
        demodulized_class_prefix_name = keywords.fetch(:demodulized_class_prefix_name, slug)
        self.work_area_managers = keywords.fetch(:work_area_managers, [])
        self.work_area = Models::WorkArea.new(
          slug: slug, partial_suffix: partial_suffix, demodulized_class_prefix_name: demodulized_class_prefix_name
        )
      end

      def call
        find_or_create_the_work_area_application_concept!
        create_work_area!
        create_processing_strategy!
        create_work_area_processing_entity!
        associate_work_area_manager_with_processing_strategy!
        work_area
      end

      private

      attr_accessor :work_area
      attr_reader :processing_strategy, :work_area_managers, :application_concept

      delegate :slug, to: :work_area

      def find_or_create_the_work_area_application_concept!
        @application_concept ||= begin
          Models::ApplicationConcept.find_by(
            class_name: work_area.class.to_s
          ) || Models::ApplicationConcept.create!(
            class_name: work_area.class.to_s, slug: 'areas', name: 'Work Area'
          )
        end
      end

      def create_work_area!
        work_area.save! unless work_area.persisted?
      end

      def create_processing_strategy!
        @processing_strategy ||= Models::Processing::Strategy.create!(
          proxy_for: application_concept, name: "#{application_concept.name} processing strategy"
        )
      end

      def create_work_area_processing_entity!
        work_area.create_processing_entity!(strategy: processing_strategy, strategy_state: processing_strategy.initial_strategy_state)
      end

      def associate_work_area_manager_with_processing_strategy!
        strategy_role = Models::Processing::StrategyRole.create!(role: work_area_manager_role, strategy: processing_strategy)
        work_area_managers.each do |manager|
          Models::Processing::EntitySpecificResponsibility.create!(
            strategy_role: strategy_role,
            entity: work_area.processing_entity,
            actor: manager
          )
        end
      end

      def work_area_manager_role
        @work_area_manager_role ||= Conversions::ConvertToRole.call(Models::Role::WORK_AREA_MANAGER)
      end

      def work_area_managers=(managers)
        @work_area_managers = Array.wrap(managers).map { |manager| Conversions::ConvertToProcessingActor.call(manager) }
      end
    end
  end
end
