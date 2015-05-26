module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for capturing a student's comment and forwarding them on to
        # the advisors.
        class RespondToAdvisorRequestForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, attribute_names: :comment, processing_subject_name: :work
          )

          def initialize(work:, attributes: {}, **keywords)
            self.work = work
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

          include Conversions::ConvertToProcessingAction
          def submit(requested_by:)
            processing_action_form.submit(requested_by: requested_by) do
              action = convert_to_processing_action(processing_action_form, scope: work)

              processing_comment = repository.record_processing_comment(
                entity: work, commenter: requested_by, comment: comment, action: action
              )
              repository.deliver_notification_for(the_thing: processing_comment, scope: action, requested_by: requested_by)
            end
          end

          private

          def input_legend
            view_context.t('etd/respond_to_advisor_request_form', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def view_context
            Draper::ViewContext.current
          end
        end
      end
    end
  end
end
