module Sipity
  module Forms
    # A container for looking up the correct forms related to work submissions.
    module WorkSubmissionForms
      module_function

      def build_the_form(work:, processing_action_name:, attributes:, repository:)
        find_the_form(work: work, processing_action_name: processing_action_name).new(
          work: work,
          processing_action_name: processing_action_name,
          attributes: attributes,
          repository: repository
        )
      end

      def find_the_form(work:, processing_action_name:)
        work_area = PowerConverter.convert(work, to: :work_area)
        form_name = "#{processing_action_name}_form".classify
        begin
          namespace = work_area.demodulized_class_prefix_name
          "Sipity::Forms::#{namespace}::WorkSubmissions::#{form_name}".constantize
        rescue NameError
          "Sipity::Forms::Core::WorkSubmissions::#{form_name}".constantize
        end
      end
      private_class_method :find_the_form
    end
  end
end
