require 'sipity/forms/processing_form'
require 'active_model/validations'
require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing a student's comment and forwarding them on to
        # the advisors.
        class RespondToAdvisorRequestForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, attribute_names: :comment, processing_subject_name: :work,
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.comment = attributes[:comment]
          end

          include ActiveModel::Validations
          validates :comment, presence: true

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', input_legend)
            markup << f.input(:comment, as: :text, autofocus: true, input_html: { class: 'form-control', required: 'required' })
          end

          # Because the underlying service handles the things that are normally
          # handled by the composed ProcessingForm.
          #
          # @see Sipity::Forms::ProcessingForm#submit
          def submit
            return false unless valid?
            save
            work
          end

          private

          def input_legend
            view_context.t('etd/respond_to_advisor_request_form', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def view_context
            Draper::ViewContext.current
          end

          def save
            Services::RequestChangesViaCommentService.call(form: self, repository: repository, requested_by: requested_by)
          end
        end
      end
    end
  end
end
