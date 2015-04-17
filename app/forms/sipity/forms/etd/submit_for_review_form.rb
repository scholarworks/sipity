module Sipity
  module Forms
    module Etd
      # Responsible for submitting the associated entity to the advisor
      # for signoff.
      class SubmitForReviewForm < Forms::StateAdvancingActionForm
        def initialize(attributes = {})
          super
          self.agree_to_terms_of_deposit = attributes[:agree_to_terms_of_deposit]
        end

        attr_reader :agree_to_terms_of_deposit
        validates :agree_to_terms_of_deposit, acceptance: { accept: true }

        def render(f:)
          markup = view_context.content_tag('legend', deposit_terms_legend)
          markup << view_context.content_tag('article', deposit_terms, class: 'legally-binding-text')
          markup << f.input(:agree_to_terms_of_deposit,
                            as: :boolean,
                            inline_label:
                            deposit_agreement,
                            input_html: { required: 'required' }, # There is no way to add true boolean attributes to simle_form fields.
                            label: false,
                            wrapper_class: 'checkbox'
                           ).html_safe
        end

        def deposit_terms_legend
          view_context.t('etd/submit_for_review', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
        end

        def deposit_terms
          view_context.t('statement_of_terms', scope: 'sipity/legal.deposit').html_safe
        end

        def deposit_agreement
          view_context.t('agree_to_terms', scope: 'sipity/legal.deposit').html_safe
        end

        private

        def view_context
          Draper::ViewContext.current
        end

        def save(requested_by:)
          super do
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
            repository.deliver_form_submission_notifications_for(the_thing: work, action: action, requested_by: requested_by)
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
