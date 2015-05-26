module Sipity
  module Services
    # This is what happens when the advisor signs off on a given form.
    class AdvisorSignsOff
      def self.call(*args)
        new(*args).call
      end

      def initialize(form:, requested_by:, on_behalf_of: requested_by, repository: default_repository)
        self.form = form
        self.repository = repository
        self.requested_by = requested_by
        self.on_behalf_of = on_behalf_of
      end

      private

      attr_writer :repository, :requested_by, :on_behalf_of

      public

      attr_reader :form, :repository, :requested_by, :on_behalf_of

      delegate :resulting_strategy_state, :action, to: :form

      def call
        log_the_event
        # Register the action that was taken
        send_confirmation_of_advisor_signoff
        handle_last_advisor_signoff if last_advisor_to_signoff?
      end

      private

      include GuardInterfaceExpectation
      def form=(input)
        guard_interface_expectation!(input, :entity, :processing_action_name)
        @form = input
      end

      def default_repository
        CommandRepository.new
      end

      def log_the_event
        repository.log_event!(entity: form, user: requested_by, event_name: form.processing_action_name)
      end

      def send_confirmation_of_advisor_signoff
        # TODO: Instead of action, prefer form.notification_scope
        repository.deliver_notification_for(the_thing: form, scope: action, requested_by: requested_by, on_behalf_of: on_behalf_of)
      end

      def handle_last_advisor_signoff
        # TODO: Instead of resulting_strategy_state, prefer coercion
        repository.update_processing_state!(entity: form, to: resulting_strategy_state)
      end

      def last_advisor_to_signoff?
        (work_collaborators_responsible_for_review - collaborators_that_have_taken_the_action_on_the_entity).empty?
      end

      def work_collaborators_responsible_for_review
        repository.work_collaborators_responsible_for_review(work: form.entity)
      end

      def collaborators_that_have_taken_the_action_on_the_entity
        repository.collaborators_that_have_taken_the_action_on_the_entity(entity: form.entity, action: form.registered_action)
      end
    end
  end
end
