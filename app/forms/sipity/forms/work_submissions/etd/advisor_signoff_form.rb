module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for submitting the associated entity to the advisor
        # for signoff.
        class AdvisorSignoffForm
          ProcessingForm.configure(form_class: self, base_class: Models::Work, attribute_names: [:agree_to_signoff])

          def initialize(work:, attributes: {}, signoff_service: default_signoff_service, **keywords)
            self.work = work
            self.processing_action_form = ProcessingForm.new(form: self, **keywords)
            self.signoff_service = signoff_service
            self.agree_to_signoff = attributes[:agree_to_signoff]
          end

          include ActiveModel::Validations
          validates :agree_to_signoff, acceptance: { accept: true }

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', advisor_signoff_legend)
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

          # TODO: Normalize translation
          def advisor_signoff_legend
            view_context.t('etd/advisor_signoff', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          # TODO: Normalize translation
          def signoff_agreement
            view_context.t('i_agree', scope: 'sipity/forms.state_advancing_actions.verification.etd/advisor_signoff').html_safe
          end

          # Instead of the processing action form's submit, I want to use the
          # underlying submit service, because so many things may be happening
          # on that form submission.
          def submit(requested_by:)
            return false unless valid?
            save(requested_by: requested_by)
            work
          end

          private

          def agree_to_signoff=(value)
            @agree_to_signoff = PowerConverter.convert_to_boolean(value)
          end

          def view_context
            Draper::ViewContext.current
          end

          attr_accessor :signoff_service
          def default_signoff_service
            Services::AdvisorSignsOff
          end

          def save(requested_by:)
            signoff_service.call(form: self, requested_by: requested_by, repository: repository)
          end
        end
      end
    end
  end
end
