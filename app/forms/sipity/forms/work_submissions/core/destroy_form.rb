require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for "deleting" a Work.
        class DestroyForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:confirm_destroy]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.confirm_destroy = attributes[:confirm_destroy]
            initialize_submission_window!
          end

          include ActiveModel::Validations
          validates :confirm_destroy, acceptance: { accept: true }
          validates :requested_by, presence: true

          def submit
            return false unless valid?
            repository.destroy_a_work(work: work)
            submission_window # Because we won't have a work
          end

          private

          def confirm_destroy=(value)
            @confirm_destroy = PowerConverter.convert(value, to: :boolean)
          end

          attr_reader :submission_window

          def initialize_submission_window!
            @submission_window = PowerConverter.convert(work, to: :submission_window)
          end
        end
      end
    end
  end
end
