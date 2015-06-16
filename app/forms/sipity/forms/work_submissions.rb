module Sipity
  module Forms
    # A container for looking up the correct forms related to work submissions.
    module WorkSubmissions
      module_function

      def build_the_form(work:, processing_action_name:, **keywords)
        find_the_form(work: work, processing_action_name: processing_action_name).
          new(work: work, processing_action_name: processing_action_name, **keywords)
      end

      def find_the_form(work:, processing_action_name:)
        work_area = PowerConverter.convert(work, to: :work_area)
        form_name = "#{processing_action_name.to_s.classify}Form"
        begin
          namespace = work_area.demodulized_class_prefix_name
          "Sipity::Forms::WorkSubmissions::#{namespace}::#{form_name}".constantize
        rescue NameError
          "Sipity::Forms::WorkSubmissions::Core::#{form_name}".constantize
        end
      end
      private_class_method :find_the_form
    end
  end
end
