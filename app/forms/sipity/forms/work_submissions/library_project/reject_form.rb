require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'sipity/forms'
module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        # Responsible for submitting the associated entity to the advisor
        # for signoff.
        class RejectForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:project_proposal_decision], template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.project_proposal_decision = attributes[:project_proposal_decision]
          end

          include ActiveModel::Validations
          validates :project_proposal_decision, presence: true

          def render(f:)
            markup = %(<legend>Reject the project proposal</legend>)
            markup << f.input(:project_proposal_decision, as: :text, input_html: { class: 'form-control' })
            markup.html_safe
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'project_proposal_decision', values: project_proposal_decision)
            end
          end
        end
      end
    end
  end
end
