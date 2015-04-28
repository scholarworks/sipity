module Sipity
  module Forms
    module Etd
      # Responsible for exposing ability for someone to comment and request
      # changes to the work on behalf of someone else.
      class RequestChangeOnBehalfOfForm < Forms::StateAdvancingActionForm
        def initialize(options = {})
          super
          self.comment = options[:comment]
          self.on_behalf_of_collaborator_extension = build_collaborator_extension
          self.on_behalf_of_collaborator_id = options[:on_behalf_of_collaborator_id]
        end

        delegate(
          :valid_on_behalf_of_collaborators,
          :on_behalf_of_collaborator,
          :on_behalf_of_collaborator_id,
          :on_behalf_of_collaborator_id=,
          :valid_on_behalf_of_collaborator_ids,
          to: :on_behalf_of_collaborator_extension
        )

        attr_accessor :comment
        private(:comment=, :on_behalf_of_collaborator_id=)

        validates :comment, presence: true
        validates :on_behalf_of_collaborator_id, presence: true, inclusion: { in: :valid_on_behalf_of_collaborator_ids }

        # @param f SimpleFormBuilder
        #
        # @return String
        def render(f:)
          markup = view_context.content_tag('legend', comment_legend)
          markup << f.input(:comment, as: :text, autofocus: true, input_html: { class: 'form-control', required: 'required' })
          markup << f.input(:on_behalf_of_collaborator_id, collection: valid_on_behalf_of_collaborators, value_method: :id)
        end

        private

        def comment_legend
          view_context.t("etd/#{enrichment_type}", scope: 'sipity/forms.state_advancing_actions.legend').html_safe
        end

        def view_context
          Draper::ViewContext.current
        end

        def save(requested_by:)
          Services::RequestChangesViaCommentService.call(
            form: self, repository: repository, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
          )
        end

        attr_accessor :on_behalf_of_collaborator_extension

        def build_collaborator_extension
          Forms::ComposableElements::OnBehalfOfCollaborator.new(form: self, repository: repository)
        end
      end
    end
  end
end
