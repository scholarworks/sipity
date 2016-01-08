require 'curly/presenter'

module Sipity
  module Controllers
    module WorkAreas
      # Responsible for rendering the form for filtering out the various
      # processing actions.
      class FilterFormPresenter < Curly::Presenter
        presents :work_area

        def select_tag_for_processing_state
          select_tag(
            work_area.input_name_for_select_processing_state,
            options_from_collection_for_select(
              work_area.processing_states_for_select, :to_s, :humanize, work_area.processing_state
            ), include_blank: true, class: 'form-control'
          ).html_safe
        end

        def select_tag_for_sort_order
          select_tag(
            work_area.input_name_for_select_sort_order,
            options_from_collection_for_select(
              work_area.order_options_for_select, :to_s, :humanize, work_area.order
            ), include_blank: true, class: 'form-control'
          ).html_safe
        end

        def submit_button(dom_class: 'btn btn-default', name: 'Filter')
          submit_tag(name, class: dom_class)
        end

        private

        attr_reader :work_area
      end
    end
  end
end
