module Sipity
  module Forms
    # This class is responsible for handling much of the form composition
    # regarding processing actions.
    #
    # Its my effort to break the inheritance cycle.
    class ProcessingForm
      def self.delegate_method_names
        [:to_processing_entity, :enrichment_type, :to_work_area, :repository, :processing_action_name]
      end

      def self.private_delegate_method_names
        [:repository]
      end

      # Code that writes code; Here is a configuration macro to help ensure we
      # have a common shape to all of our forms.
      def self.configure(form_class:, base_class:, attribute_names:, **keywords)
        processing_form_class = self
        form_class.module_exec do
          class_attribute(:attribute_names, instance_writer: :false) unless respond_to?(:attribute_names=)
          self.attribute_names = Array.wrap(attribute_names)

          class_attribute(:processing_subject_name, instance_writer: :false) unless respond_to?(:processing_subject_name=)
          self.processing_subject_name = keywords.fetch(:processing_subject_name) do
            base_class.name.sub(/.*::(\w+)::(\w+)\Z/, '\2').underscore
          end

          class_attribute(:processing_action_form_builder, instance_writer: :false) unless respond_to?(:processing_action_form_builder=)
          self.processing_action_form_builder = keywords.fetch(:processing_action_form_builder) { processing_form_class }

          class_attribute :base_class unless respond_to?(:base_class=)
          self.base_class = base_class

          class_attribute :policy_enforcer unless respond_to?(:policy_enforcer=)
          self.policy_enforcer = keywords.fetch(:policy_enforcer) do
            base_class.name.sub(/::(\w+)::(\w+)\Z/, '::Policies::\2Policy').constantize
          end

          class_attribute :template unless respond_to?(:template=)
          self.template = keywords.fetch(:template) { name.demodulize.sub(/Form\Z/, '').underscore }

          class << self
            delegate :model_name, :human_attribute_name, to: :base_class
            private(:attribute_names=)
          end

          delegate(*processing_form_class.delegate_method_names, to: :processing_action_form)
          private(*processing_form_class.private_delegate_method_names)

          private

          attr_reader :processing_action_form
          attr_writer(*Array.wrap(attribute_names))
          attr_writer processing_subject_name

          public

          attr_reader(*Array.wrap(attribute_names))
          attr_reader processing_subject_name
          alias_method :entity, processing_subject_name

          def persisted?
            false
          end

          include GuardInterfaceExpectation
          def processing_action_form=(input)
            guard_interface_expectation!(input, :submit, :repository, :to_work_area, :to_processing_entity, :processing_action_name)
            @processing_action_form = input
          end
        end
      end

      def initialize(form:, repository: default_repository, **keywords)
        self.form = form
        self.repository = repository
        self.processing_action_name = keywords.fetch(:processing_action_name) { default_processing_action_name }
      end

      delegate :valid?, :entity, to: :form

      def submit(requested_by:)
        return false unless valid?
        @registered_action = repository.register_processing_action_taken_on_entity(
          entity: entity, action: processing_action_name, requested_by: requested_by
        )
        repository.log_event!(entity: entity, user: requested_by, event_name: event_name)
        yield if block_given?
        repository.update_processing_state!(entity: entity, to: to_processing_action.resulting_strategy_state)
        entity
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

      def to_processing_action
        Conversions::ConvertToProcessingAction.call(processing_action_name, scope: entity)
      end

      private

      def event_name
        "#{processing_action_name}/submit"
      end

      attr_writer :repository, :processing_action_name
      attr_reader :form

      def default_repository
        CommandRepository.new
      end

      include GuardInterfaceExpectation
      def form=(input)
        guard_interface_expectation!(input, :valid?, :base_class, :entity)
        # I want to use send
        guard_interface_expectation!(input, include_all: true)
        @form = input
      end

      def default_processing_action_name
        form.class.name.demodulize.sub(/Form\Z/, '').underscore
      end
    end
  end
end
