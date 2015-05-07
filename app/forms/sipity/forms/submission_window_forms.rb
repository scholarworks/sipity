module Sipity
  module Forms
    # A container for looking up the correct forms related to work areas.
    module SubmissionWindowForms
      module_function

      def build_the_form(submission_window:, processing_action_name:, attributes:)
        # ASSUMPTION: We will not have custom forms for the given
        # Submission Window.
        find_the_form(submission_window: submission_window, processing_action_name: processing_action_name).new(
          submission_window: submission_window,
          processing_action_name: processing_action_name,
          attributes: attributes
        )
      end

      def find_the_form(submission_window:, processing_action_name:)
        work_area = PowerConverter.convert(submission_window, to: :work_area)
        form_name = "#{processing_action_name}_form".classify
        begin
          namespace = work_area.demodulized_class_prefix_name
          "Sipity::Forms::#{namespace}::SubmissionWindows::#{form_name}".constantize
        rescue NameError
          "Sipity::Forms::Core::SubmissionWindows::#{form_name}".constantize
        end
      end
      private_class_method :find_the_form
    end
  end
end
