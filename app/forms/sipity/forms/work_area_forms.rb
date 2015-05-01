module Sipity
  module Forms
    # A container for looking up the correct forms related to work areas.
    module WorkAreaForms
      module_function

      def build_the_form(work_area:, processing_action_name:, attributes:)
        namespace = work_area.demodulized_class_prefix_name
        form_name = "#{processing_action_name}_form".classify
        "#{self}::#{namespace}::#{form_name}".constantize.new(
          work_area: work_area,
          processing_action_name: processing_action_name,
          attributes: attributes
        )
      end
    end
  end
end
