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
          markup = view_context.content_tag('legend', submission_terms)
          markup << view_context.content_tag(
            'article',
            I18n.t('sipity/terms.terms_of_deposit_html').html_safe,
            class: 'terms-of-deposit legally-binding-text'
          )
          markup <<  f.input(
            :agree_to_terms_of_deposit,
            as: :boolean,
            inline_label: I18n.t('activemodel.attributes.sipity/forms/state_advancing_action.agree_to_terms_of_deposit'),
            input_html: { required: 'required' }, # There is no way to add boolean attributes to simle_form fields. This will have to do.
            label: false,
            wrapper_class: 'checkbox'
          )
          markup.html_safe
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
