module Sipity
  module Forms
    module Etd
      # Responsible for capturing advisor comments and forwarding them on to
      # the student.
      class AdvisorRequestsChangeForm < Forms::StateAdvancingActionForm
        def initialize(attributes = {})
          super
          self.comment = attributes[:comment]
        end

        attr_accessor :comment
        private(:comment=)
        validates :comment, presence: true

        # @param f SimpleFormBuilder
        #
        # @return String
        def render(f:)
          markup = view_context.content_tag('legend', comment_legend)
          markup << f.input(:comment, as: :text, autofocus: true, input_html: { class: 'form-control', required: 'required' })
        end

        private

        def comment_legend
          view_context.t('etd/advisor_requests_change', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
        end

        def view_context
          Draper::ViewContext.current
        end

        def save(requested_by:)
          # TODO: Consider extracting common behavior to a service method (see RequestChangeOnBehalfOfForm#save)
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
