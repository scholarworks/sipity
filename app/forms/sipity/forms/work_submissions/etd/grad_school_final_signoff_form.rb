require 'sipity/forms/processing_form'
require 'active_model/validations'
require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for submitting the final Grad School approval.
        class GradSchoolFinalSignoffForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, attribute_names: [], processing_subject_name: :work,
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
          end

          include ActiveModel::Validations

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(*)
            %(
              <legend>
                Prior to the cataloging portion being complete, the Graduate School had signed off on this ETD.
                At the time, the cataloging portion of this process was incomplete.
                With the cataloging workflow for ETDs completed, you are now finalizing that workflow.
              </legend>
            ).html_safe
          end

          delegate :submit, to: :processing_action_form
        end
      end
    end
  end
end
