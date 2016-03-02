module Sipity
  module Forms
    # A container for looking up the correct forms related to work submissions.
    module WorkSubmissions
      module_function

      def build_the_form(work:, processing_action_name:, **keywords)
        find_the_form(work: work, processing_action_name: processing_action_name).
          new(work: work, processing_action_name: processing_action_name, **keywords)
      end

      def find_the_form(processing_action_name:, **keywords)
        work_area_thing = keywords[:work] || keywords.fetch(:work_area)
        work_area = PowerConverter.convert(work_area_thing, to: :work_area)
        form_name = "#{processing_action_name.to_s.classify}Form"
        begin
          namespace = work_area.demodulized_class_prefix_name
          "Sipity::Forms::WorkSubmissions::#{namespace}::#{form_name}".constantize
        rescue NameError
          "Sipity::Forms::WorkSubmissions::Core::#{form_name}".constantize
        end
      end
    end
  end
end
