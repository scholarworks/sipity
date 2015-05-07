module Sipity
  module Forms
    # A container for looking up the correct forms related to work areas.
    module SubmissionWindowForms
      module_function

      def build_the_form(submission_window:, processing_action_name:, attributes:)
        work_area = PowerConverter.convert(submission_window, to: :work_area)
        namespace = work_area.demodulized_class_prefix_name
        form_name = "#{processing_action_name}_form".classify

        # ASSUMPTION: We will not have custom forms for the given
        # Submission Window.
        "Sipity::Forms::#{namespace}::SubmissionWindows::#{form_name}".constantize.new(
          submission_window: submission_window,
          processing_action_name: processing_action_name,
          attributes: attributes
        )
      end
    end
  end
end
