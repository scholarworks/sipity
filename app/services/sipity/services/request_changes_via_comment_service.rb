module Sipity
  module Services
    # When someone has requested changes via a comment, this is the service that
    # can be used as a foundation for handling that comment.
    class RequestChangesViaCommentService
      def self.call(**keywords)
        new(**keywords).call
      end

      def initialize(form:, requested_by:, on_behalf_of: requested_by, repository: default_repository)
        self.form = form
        self.requested_by = requested_by
        self.on_behalf_of = on_behalf_of
        self.repository = repository
      end

      def call
        send_notification_for(processing_comment: record_processing_comment)
        log_event
        register_action_taken
        update_processing_state
      end

      def record_processing_comment
        repository.record_processing_comment(
          entity: form.entity, commenter: on_behalf_of, comment: form.comment, action: form.to_processing_action
        )
      end

      def send_notification_for(processing_comment:)
        repository.deliver_notification_for(
          the_thing: processing_comment, scope: form.to_processing_action, requested_by: requested_by, on_behalf_of: on_behalf_of
        )
      end

      def register_action_taken
        repository.register_processing_action_taken_on_entity(
          entity: form.entity, action: form.to_processing_action, requested_by: requested_by, on_behalf_of: on_behalf_of
        )
      end

      def log_event
        repository.log_event!(entity: form.entity, user: requested_by, event_name: event_name)
      end

      def update_processing_state
        # TODO: Violation of the Law of Demeter; Create a new method that can optionally transition state based on the
        # action taken.
        repository.update_processing_state!(entity: form.entity, to: form.to_processing_action.resulting_strategy_state)
      end

      private

      attr_reader :form
      attr_accessor :requested_by, :on_behalf_of, :repository

      include GuardInterfaceExpectation
      def form=(input)
        guard_interface_expectation!(input, :entity, :to_processing_action, :processing_action_name, :comment)
        @form = input
      end

      # TODO: This is a duplication of knowledge; Consider a Coercion method?
      def event_name
        "#{form.processing_action_name}/submit"
      end

      def default_repository
        CommandRepository.new
      end
    end
  end
end
