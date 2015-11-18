require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for calling the ETD Ingester
        class IngestCompletedForm
          # @see https://github.com/ndlib/curatend-batch/blob/master/webhook.md
          JOB_STATE_SUCCESS = 'success'.freeze

          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work, attribute_names: [:job_state]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.job_state = attributes.fetch(:job_state, nil)
          end

          include ActiveModel::Validations
          validates :job_state, inclusion: { in: [JOB_STATE_SUCCESS] }

          delegate :submit, to: :processing_action_form
        end
      end
    end
  end
end
