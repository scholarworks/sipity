require 'sipity/forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for the submission of a completed ULRA review
        class SubmitCompletedReviewForm
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

          delegate :submit, to: :processing_action_form

          def render(*)
            %(<legend>The ULRA Committee has completed its review of this submission.</legend>).html_safe
          end
        end
      end
    end
  end
end
