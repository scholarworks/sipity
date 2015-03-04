module Sipity
  module Forms
    module Etd
      # Responsible for submitting the associated entity to the advisor
      # for signoff.
      class SubmitForReviewForm < Forms::StateAdvancingAction
        def initialize(attributes = {})
          super
          self.agree_to_terms_of_deposit = attributes[:agree_to_terms_of_deposit]
        end

        attr_reader :agree_to_terms_of_deposit
        validates :agree_to_terms_of_deposit, acceptance: { accept: true }

        def render(f:)
          view_context.content_tag('legend', submission_terms) +
            f.input(
              :agree_to_terms_of_deposit,
              as: :boolean,
              inline_label: I18n.t('activemodel.attributes.sipity/forms/state_advancing_action.agree_to_terms_of_deposit'),
              label: false,
              wrapper_class: 'checkbox'
            )
        end

        def submission_terms
          view_context.t('submission_terms', scope: 'sipity/forms.etd/submit_for_review_form').html_safe
        end

        private

        def view_context
          Draper::ViewContext.current
        end

        def save(requested_by:)
          super do
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
            repository.send_notification_for_entity_trigger(
              notification: "confirmation_of_entity_submitted_for_review", entity: work, acting_as: 'creating_user'
            )
            repository.send_notification_for_entity_trigger(
              notification: "entity_ready_for_review", entity: work, acting_as: ['etd_reviewer', 'advisor']
            )
          end
        end

        include Conversions::ConvertToBoolean
        def agree_to_terms_of_deposit=(value)
          @agree_to_terms_of_deposit = convert_to_boolean(value)
        end
      end
    end
  end
end
