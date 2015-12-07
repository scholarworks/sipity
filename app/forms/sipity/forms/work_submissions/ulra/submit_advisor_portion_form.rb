require 'sipity/forms/processing_form'
require 'active_model/validations'
require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for submitting the associated entity to the advisor
        # for signoff.
        class SubmitAdvisorPortionForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, attribute_names: [],
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
          end

          include ActiveModel::Validations
          validates :requested_by, presence: true
          validates :work, presence: true

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(*)
            %(<legend>I have completed the advisor portion of the Undergraduate Library Research Award submission</legend>).strip.html_safe
          end

          delegate :submit, to: :processing_action_form
        end
      end
    end
  end
end
