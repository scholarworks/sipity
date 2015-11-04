module Sipity
  module Queries
    # Queries
    module WorkQueries
      def find_work(work_id)
        find_work_by(id: work_id)
      end

      def find_work_by(id:)
        Models::Work.includes(:processing_entity, work_submission: [:work_area, :submission_window]).find(id)
      end

      def build_dashboard_view(user:, filter: {}, repository: self, page:)
        Decorators::DashboardView.new(repository: repository, user: user, filter: filter, page: page)
      end

      # TODO: Rename this method; Keeping it separate for now.
      def build_work_submission_processing_action_form(work:, processing_action_name:, **keywords)
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::WorkSubmissions.build_the_form(
          work: work,
          processing_action_name: processing_action_name,
          repository: self,
          **keywords
        )
      end

      # @todo Refactor places that use #find_works_for to leverage #find_works_via_search
      def find_works_for(user:, processing_state: nil, repository: self, proxy_for_type: Models::Work, page: nil)
        scope = repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
          user: user, proxy_for_type: proxy_for_type, filter: { processing_state: processing_state }
        )
        return scope unless page
        scope.page(page).per(15)
      end

      def find_works_via_search(criteria:, repository: self)
        parameters = extract_search_paramters_from(criteria: criteria)
        scope = repository.scope_proxied_objects_for_the_user_and_proxy_for_type(**parameters)
        apply_work_area_filter_to(scope: scope, criteria: criteria)
      end

      def extract_search_paramters_from(criteria:)
        search_parameters = {
          user: criteria.user, proxy_for_type: Models::Work, filter: { processing_state: criteria.processing_state }, order: criteria.order
        }
        search_parameters = search_parameters.merge(page: criteria.page, per: criteria.per) if criteria.page
        search_parameters
      end
      private :extract_search_paramters_from

      def apply_work_area_filter_to(scope:, criteria:)
        return scope unless criteria.work_area
        work_submissions = Models::WorkSubmission.arel_table
        work_area = PowerConverter.convert(criteria.work_area, to: :work_area)
        scope.where(
          Models::Work.arel_table[:id].in(
            work_submissions.project(work_submissions[:work_id]).where(work_submissions[:work_area_id].eq(work_area.id))
          )
        )
      end
      private :apply_work_area_filter_to

      def work_access_right_code(work:)
        work.access_right.access_right_code
      end
    end
  end
end
