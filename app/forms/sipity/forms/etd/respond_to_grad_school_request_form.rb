module Sipity
  module Forms
    module Etd
      # Responsible for capturing a student's comment and forwarding them on to
      # the grad school.
      class RespondToGradSchoolRequestForm < Forms::StateAdvancingActionForm
        def initialize(attributes = {})
          super
          @comment = attributes[:comment]
        end

        attr_reader :comment
        validates :comment, presence: true

        # @param f SimpleFormBuilder
        #
        # @return String
        def render(f:)
          markup = view_context.content_tag('legend', input_legend)
          markup << f.input(:comment, as: :text, autofocus: true, input_html: { class: 'form-control', required: 'required' })
        end

        private

        def input_legend
          view_context.t('etd/respond_to_grad_school_request_form', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
        end

        def view_context
          Draper::ViewContext.current
        end

        def save(requested_by:)
          super do
            processing_comment = repository.record_processing_comment(
              entity: work, commenter: requested_by, comment: comment, action: action
            )
            repository.deliver_notification_for(the_thing: processing_comment, scope: action, requested_by: requested_by)
            repository.update_processing_state!(entity: work, to: action.resulting_strategy_state)
          end
        end
      end
    end
  end
end
