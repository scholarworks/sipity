module Sipity
  module Services
    # This is what happens when the advisor signs off on a given form.
    class AdvisorSignsOff
      def self.call(*args)
        new(*args).call
      end

      def initialize(form:, requested_by:, repository: default_repository)
        @form = form
        @repository = repository
        @requested_by = requested_by
      end

      attr_reader :form, :repository, :requested_by

      def call
        if last_advisor_to_signoff?
          handle_last_advisor_signoff
        else
          handle_more_advisors_require_signoff
        end
      end

      private

      def default_repository
        CommandRepository.new
      end

      def handle_last_advisor_signoff
        repository.update_processing_state!(entity: form, to: form.resulting_strategy_state)
        repository.send_notification_for_entity_trigger(
          notification: 'ready_for_grad_school_review', entity: form, acting_as: 'etd_reviewer'
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

      def last_advisor_to_signoff?
        (work_collaborators_responsible_for_review - collaborators_that_have_taken_the_action_on_the_entity).empty?
      end

      def work_collaborators_responsible_for_review
        repository.work_collaborators_responsible_for_review(work: form.work)
      end

      def collaborators_that_have_taken_the_action_on_the_entity
        repository.collaborators_that_have_taken_the_action_on_the_entity(entity: form.work, action: form.action)
      end
    end
  end
end
