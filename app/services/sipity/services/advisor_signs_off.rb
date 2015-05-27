module Sipity
  module Services
    # This is what happens when the advisor signs off on a given form.
    class AdvisorSignsOff
      def self.call(*args)
        new(*args).call
      end

      def initialize(form:, requested_by:, on_behalf_of: requested_by, **keywords)
        self.repository = keywords.fetch(:repository) { default_repository }
        self.form = form
        self.requested_by = requested_by
        self.on_behalf_of = on_behalf_of
        self.also_register_as = keywords.fetch(:also_register_as) { default_also_register_as }
        self.action = default_action
      end

      private

      attr_writer :repository, :requested_by, :on_behalf_of, :action
      attr_reader :action

      public

      attr_reader :form, :repository, :requested_by, :on_behalf_of, :also_register_as

      def call
        log_the_event
        register_the_processing_actions
        send_confirmation_of_advisor_signoff
        handle_last_advisor_signoff if last_advisor_to_signoff?
      end

      private

      include GuardInterfaceExpectation
      def form=(input)
        guard_interface_expectation!(input, :entity, :processing_action_name, :to_processing_action)
        @form = input
      end

      include Conversions::ConvertToProcessingAction
      def also_register_as=(input)
        @also_register_as = Array.wrap(input).map { |an_action| convert_to_processing_action(an_action, scope: form.entity) }
      end

      def default_repository
        CommandRepository.new
      end

      def default_also_register_as
        []
      end

      def default_action
        form.to_processing_action
      end

      def log_the_event
        repository.log_event!(entity: form.entity, user: requested_by, event_name: form.processing_action_name)
      end

      def register_the_processing_actions
        [action, also_register_as].flatten.each do |an_action|
          repository.register_processing_action_taken_on_entity(
            entity: form.entity, action: an_action, requested_by: requested_by, on_behalf_of: on_behalf_of
          )
        end
      end

      def send_confirmation_of_advisor_signoff
        repository.deliver_notification_for(the_thing: form, scope: action, requested_by: requested_by, on_behalf_of: on_behalf_of)
      end

      def handle_last_advisor_signoff
        repository.update_processing_state!(entity: form.entity, to: action.resulting_strategy_state)
      end

      def last_advisor_to_signoff?
        (work_collaborators_responsible_for_review - collaborators_that_have_taken_the_action_on_the_entity).empty?
      end

      def work_collaborators_responsible_for_review
        repository.work_collaborators_responsible_for_review(work: form.entity)
      end

      def collaborators_that_have_taken_the_action_on_the_entity
        repository.collaborators_that_have_taken_the_action_on_the_entity(entity: form.entity, actions: action)
      end
    end
  end
end
