require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for calling the ETD Ingester
        class IngestCompletedForm
          ProcessingForm.configure(form_class: self, base_class: Models::Work, processing_subject_name: :work, attribute_names: [])

          def initialize(work:, requested_by:, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
          end

          include ActiveModel::Validations

          delegate :submit, to: :processing_action_form
        end
      end
    end
  end
end
