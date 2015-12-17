require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'sipity/forms'
module Sipity
  module Forms
    module WorkSubmissions
      module LibraryProject
        # Responsible for submitting the associated entity to the advisor
        # for signoff.
        class ApproveForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [], template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
          end

          include ActiveModel::Validations

          def render(*)
            %(<legend>Approve the project proposal</legend>).html_safe
          end

          delegate :submit, to: :processing_action_form
        end
      end
    end
  end
end
