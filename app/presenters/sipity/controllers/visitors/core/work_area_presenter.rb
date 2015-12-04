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

          # Responsible for rendering a given work within the context of the Dashboard.
          #
          # @note This could be extracted outside of this namespace
          class WorkPresenter < Curly::Presenter
            presents :work

            def path
              PowerConverter.convert(work, to: :access_path)
            end

            def work_type
              work.work_type.to_s.humanize
            end

            def creator_names_to_sentence
              creators.to_sentence
            end

            def program_names_to_sentence
              Array.wrap(repository.work_attribute_values_for(work: work, key: 'program_name')).to_sentence
            end

            def date_created
              work.created_at.strftime('%a, %d %b %Y')
            end

            def processing_state
              work.processing_state.to_s.humanize
            end

            def title
              work.title.to_s.html_safe
            end

            private

            attr_reader :work
            def creators
              # The repository comes from the underlying context; Which is likely a controller.
              @creators ||= Array.wrap(repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER))
            end
          end
        end
      end
    end
  end
end
