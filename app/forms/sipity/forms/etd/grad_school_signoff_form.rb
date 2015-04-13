module Sipity
  module Forms
    module Etd
      # Responsible for submitting the final Grad School approval.
      class GradSchoolSignoffForm < Forms::StateAdvancingActionForm
        def initialize(attributes = {})
          super
          self.agree_to_signoff = attributes[:agree_to_signoff]
        end

        attr_reader :agree_to_signoff
        validates :agree_to_signoff, acceptance: { accept: true }

        # @param f SimpleFormBuilder
        #
        # @return String
        def render(f:)
          markup = view_context.content_tag('legend', legend)
          markup << f.input(
            :agree_to_signoff,
            as: :boolean,
            inline_label:
            signoff_agreement,
            input_html: { required: 'required' }, # There is no way to add true boolean attributes to simle_form fields.
            label: false,
            wrapper_class: 'checkbox'
          ).html_safe
        end

        def legend
          view_context.t('etd/grad_school_signoff', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
        end

        def signoff_agreement
          view_context.t('i_agree', scope: 'sipity/forms.state_advancing_actions.verification.etd/grad_school_signoff').html_safe
        end

        private

        include Conversions::ConvertToBoolean
        def agree_to_signoff=(value)
          @agree_to_signoff = convert_to_boolean(value)
        end

        def view_context
          Draper::ViewContext.current
        end

        def save(requested_by:)
          super do
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
            repository.send_notification_for_entity_trigger(
              notification: "confirmation_of_grad_school_signoff", entity: work, acting_as: ['creating_user', 'etd_reviewer']
            )
          end
        end
      end
    end
  end
end
