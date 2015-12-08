require 'active_support/core_ext/array/wrap'
require 'sipity/controllers/work_areas/core/show_presenter'

module Sipity
  module Controllers
    module Visitors
      module Core
        # Responsible for presenting a work area
        #
        # TODO: Consider this presenter as a more complicated composition of
        #   both work area and submission window; That is more reflective of
        #   the reality.
        class WorkAreaPresenter < Sipity::Controllers::WorkAreas::ShowPresenter
          presents :work_area
          def initialize(*args)
            super
            initialize_submission_window_variables!
          end

          def start_a_submission_path
            File.join(PowerConverter.convert(submission_window, to: :processing_action_root_path), start_a_submission_action.name)
          end

          def filter_form(dom_class: 'form-inline', method: 'get', &block)
            form_tag(request.path, method: method, class: dom_class, &block)
          end

          def works
            @works ||= repository.find_works_via_search(criteria: search_criteria)
          end

          def paginate_works
            paginate(works)
          end

          private

          # TODO: There is a more elegant way to do this, but for now it is the
          # way things shall be done.
          ACTION_NAME_THAT_IS_HARD_CODED = 'start_a_submission'.freeze
          SUBMISSION_WINDOW_SLUG_THAT_IS_HARD_CODED = 'start'.freeze

          include Conversions::ConvertToProcessingAction
          def initialize_submission_window_variables!
            # Critical assumption about ETD structure. This is not a long-term
            # solution, but one to get things out the door.
            self.submission_window = repository.find_submission_window_by(
              slug: SUBMISSION_WINDOW_SLUG_THAT_IS_HARD_CODED, work_area: work_area
            )
            self.start_a_submission_action = convert_to_processing_action(ACTION_NAME_THAT_IS_HARD_CODED, scope: submission_window)
          end

          def search_criteria
            @search_criteria ||= begin
              Parameters::SearchCriteriaForWorksParameter.new(
                user: current_user, processing_state: work_area.processing_state, page: work_area.page, order: work_area.order,
                repository: repository, work_area: work_area
              )
            end
          end

          attr_accessor :submission_window, :start_a_submission_action
        end
      end
    end
  end
end
