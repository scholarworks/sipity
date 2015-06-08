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

          def initialize(work:, attributes: {}, **keywords)
            self.work = work
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.confirm_destroy = attributes[:confirm_destroy]
            initialize_submission_window!
          end

          include ActiveModel::Validations
          validates :confirm_destroy, acceptance: { accept: true }

          def submit(*)
            return false unless valid?
            repository.destroy_a_work(work: work)
            submission_window # Because we won't have a work
          end

          private

          def confirm_destroy=(value)
            @confirm_destroy = PowerConverter.convert_to_boolean(value)
          end

          attr_reader :submission_window

          def initialize_submission_window!
            @submission_window = PowerConverter.convert_to_submission_window(work)
          end
        end
      end
    end
  end
end
