module Sipity
  module Services
    # When someone has requested changes via a comment, this is the service that
    # can be used as a foundation for handling that comment.
    class RequestChangesService
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
          entity: work, commenter: on_behalf_of, comment: comment, action: action
        )
      end

      def send_notification_for(processing_comment:)
        repository.deliver_notification_for(
          the_thing: processing_comment, scope: action, requested_by: requested_by, on_behalf_of: on_behalf_of
        )
      end

      def register_action_taken
        repository.register_action_taken_on_entity(
          work: work, enrichment_type: enrichment_type, requested_by: requested_by, on_behalf_of: on_behalf_of
        )
      end

      def log_event
        repository.log_event!(entity: work, user: requested_by, event_name: event_name)
      end

      def update_processing_state
        repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
      end

      private

      delegate :work, :event_name, :comment, :enrichment_type, :action, to: :form

      attr_accessor :form, :repository
      attr_accessor :requested_by, :on_behalf_of

      def default_repository
        CommandRepository.new
      end
    end
  end
end
