module Sipity
  module Forms
    # A container module
    module WorkAreas
      module_function

      def build_the_form(work_area:, processing_action_name:, **keywords)
        find_the_form(work_area: work_area, processing_action_name: processing_action_name).
          new(work_area: work_area, processing_action_name: processing_action_name, **keywords)
      end

      def find_the_form(work_area:, processing_action_name:)
        form_name = "#{processing_action_name}_form".classify
        begin
          namespace = work_area.demodulized_class_prefix_name
          "Sipity::Forms::WorkAreas::#{namespace}::#{form_name}".constantize
        rescue NameError
          "Sipity::Forms::WorkAreas::Core::#{form_name}".constantize
        end
      end
      private_class_method :find_the_form
    end
  end
end
