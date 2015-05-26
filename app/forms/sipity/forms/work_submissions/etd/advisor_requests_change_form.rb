module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing advisor comment and forwarding them on to
        # the student.
        class AdvisorRequestsChangeForm
          ProcessingForm.configure(form_class: self, base_class: Models::Work, attribute_names: :comment, processing_subject_name: :work)

          def initialize(work:, attributes: {}, **keywords)
            self.work = work
            self.processing_action_form = ProcessingForm.new(form: self, **keywords)
            self.comment = attributes[:comment]
          end

          include ActiveModel::Validations
          validates :comment, presence: true

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', comment_legend)
            markup << f.input(:comment, as: :text, autofocus: true, input_html: { class: 'form-control', required: 'required' })
          end

          # Because the underlying service handles the things that are normally
          # handled by the composed ProcessingForm.
          #
          # @see Sipity::Forms::ProcessingForm#submit
          def submit(requested_by:)
            return false unless valid?
            save(requested_by: requested_by)
            work
          end

          private

          def comment_legend
            # TODO: Normalize translation scope
            view_context.t('etd/advisor_requests_change', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def view_context
            Draper::ViewContext.current
          end

          def save(requested_by:)
            Services::RequestChangesViaCommentService.call(
              form: self, repository: repository, requested_by: requested_by
            )
          end
        end
      end
    end
  end
end
