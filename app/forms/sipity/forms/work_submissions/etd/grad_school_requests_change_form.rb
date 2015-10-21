require 'sipity/forms/processing_form'
require 'active_model/validations'
require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing comments and forwarding them on to the
        # student.
        class GradSchoolRequestsChangeForm
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

          # @param form SimpleFormBuilder
          #
          # @return String
          def render(form:)
            markup = view_context.content_tag('legend', grad_school_requests_change_legend)
            markup << form.input(:comment, as: :text, autofocus: true, input_html: { class: 'form-control', required: 'required' })
          end

          def grad_school_requests_change_legend
            view_context.t('etd/grad_school_requests_change', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
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
