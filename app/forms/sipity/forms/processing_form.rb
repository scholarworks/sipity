module Sipity
  module Forms
    # This class is responsible for handling much of the form composition
    # regarding processing actions.
    #
    # Its my effort to break the inheritance cycle.
    class ProcessingForm
      def self.delegate_method_names
        [:to_processing_entity, :enrichment_type, :to_work_area, :repository, :submit, :processing_action_name]
      end

      def self.private_delegate_method_names
        [:repository]
      end

      def initialize(form:, repository: default_repository, **keywords)
        self.form = form
        self.repository = repository
        self.processing_action_name = keywords.fetch(:processing_action_name) { default_processing_action_name }
      end

      delegate :valid?, :entity, to: :form

      def submit(requested_by:)
        return false unless valid?
        save(requested_by: requested_by)
      end

      attr_reader :repository, :processing_action_name, :registered_action
      alias_method :to_registered_action, :registered_action
      alias_method :enrichment_type, :processing_action_name
      deprecate enrichment_type: "Use :processing_action_name instead"

      def to_processing_entity
        Conversions::ConvertToProcessingEntity.call(entity)
      end

      def to_work_area
        PowerConverter.convert_to_work_area(entity)
      end

      private

      def event_name
        "#{processing_action_name}/submit"
      end

      attr_writer :repository, :processing_action_name
      attr_reader :form

      def save(requested_by:)
        @registered_action = repository.register_processing_action_taken_on_entity(
          entity: entity, action: processing_action_name, requested_by: requested_by
        )
        repository.log_event!(entity: entity, user: requested_by, event_name: event_name)

        form.save(requested_by: requested_by)
      end

      def default_repository
        CommandRepository.new
      end

      include GuardInterfaceExpectation
      def form=(input)
        guard_interface_expectation!(input, :valid?, :save, :base_class, :entity)
        @form = input
      end

      def default_processing_action_name
        form.class.name.demodulize.sub(/Form\Z/, '').underscore
      end
    end
  end
end
