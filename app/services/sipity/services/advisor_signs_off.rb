module Sipity
  module Services
    class AdvisorSignsOff
      # REVIEW: Is this the correct way to be thinking about this? I have a
      #   query that is crossing the boundaries of two systems. But for now
      #   RED->GREEN->REFACTOR
      include Queries::CollaboratorQueries
      include Queries::ProcessingQueries

      def initialize(form:, requested_by:, repository:)
        @form = form
        @repository = repository
        @requested_by = requested_by
      end

      attr_reader :form, :repository, :requested_by

      def call
        if is_last_advisor_to_signoff?
          handle_last_advisor_signoff
        else
          handle_more_advisors_require_signoff
        end
      end

      private
      def handle_last_advisor_signoff
        repository.update_processing_state!(entity: form, to: form.resulting_strategy_state)
        repository.send_notification_for_entity_trigger(
          notification: 'entity_ready_for_review', entity: form, acting_as: 'etd_reviewer'
        )
        repository.send_notification_for_entity_trigger(
          notification: 'all_advisors_have_signed_off', entity: form, acting_as: 'creating_user'
        )
      end

      def handle_more_advisors_require_signoff
        repository.send_notification_for_entity_trigger(
          notification: "advisor_signoff_but_still_more_to_go", entity: form, acting_as: 'creating_user'
        )
      end

      private

      def is_last_advisor_to_signoff?
        fail NotImplementedError, "Expected #{self.class} to define ##{__method__}"
      end
    end
  end
end
