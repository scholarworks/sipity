module Sipity
  module Forms
    # A container for looking up the correct forms related to work areas.
    module WorkAreaForms
      module_function

      def build_the_form(work_area:, processing_action_name:, attributes:, repository:)
        find_the_form(work_area: work_area, processing_action_name: processing_action_name).new(
          work_area: work_area,
          processing_action_name: processing_action_name,
          attributes: attributes,
          repository: repository
        )
      end

      def find_the_form(work_area:, processing_action_name:)
        form_name = "#{processing_action_name}_form".classify
        begin
          namespace = work_area.demodulized_class_prefix_name
          "Sipity::Forms::#{namespace}::WorkAreas::#{form_name}".constantize
        rescue NameError
          "Sipity::Forms::Core::WorkAreas::#{form_name}".constantize
        end
      end
      private_class_method :find_the_form
    end
  end
end
