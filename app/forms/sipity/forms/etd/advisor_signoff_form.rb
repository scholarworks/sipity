module Sipity
  module Forms
    module Etd
      # Responsible for submitting the associated entity to the advisor
      # for signoff.
      class AdvisorSignoffForm < Forms::StateAdvancingAction
        def initialize(attributes = {})
          super
          @signoff_service = attributes.fetch(:signoff_service) { default_signoff_service }
        end

        attr_reader :signoff_service
        attr_reader :agree_to_signoff
        validates :agree_to_signoff, acceptance: { accept: true }

        # @param f SimpleFormBuilder
        #
        # @return String
        def render(f:)
          markup = view_context.content_tag('legend', advisor_signoff_legend)
          markup << f.input(:agree_to_signoff,
                            as: :boolean,
                            inline_label:
                            signoff_agreement,
                            input_html: { required: 'required' }, # There is no way to add true boolean attributes to simle_form fields.
                            label: false,
                            wrapper_class: 'checkbox'
                           ).html_safe
        end

        def advisor_signoff_legend
          view_context.t('etd/advisor_signoff', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
        end

        def signoff_agreement
          view_context.t('i_agree', scope: 'sipity/forms.state_advancing_actions.verification.etd/advisor_signoff').html_safe
        end

        private

        def view_context
          Draper::ViewContext.current
        end

        private :signoff_service
        def default_signoff_service
          Services::AdvisorSignsOff
        end

        def save(requested_by:)
          super do
            signoff_service.call(form: self, requested_by: requested_by, repository: repository)
          end
        end
      end
    end
  end
end
