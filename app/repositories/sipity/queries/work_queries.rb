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

      def build_dashboard_view(user:, filter: {}, repository: self)
        Decorators::DashboardView.new(repository: repository, user: user, filter: filter)
      end

      # TODO: Rename this method; Keeping it separate for now.
      def build_work_submission_processing_action_form(work:, processing_action_name:, attributes: {}, repository: self)
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::WorkSubmissions.build_the_form(
          work: work,
          processing_action_name: processing_action_name,
          attributes: attributes,
          repository: repository
        )
      end

      # @todo: Is there a Parameter Object that makes more sense?
      def find_works_for(user:, processing_state: nil, repository: self, proxy_for_type: Models::Work)
        repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
          user: user, proxy_for_type: proxy_for_type, filter: { processing_state: processing_state }
        )
      end

      def find_works_via_search(criteria:, repository: self)
        repository.scope_proxied_objects_for_the_user_and_proxy_for_type(
          user: criteria.user, proxy_for_type: criteria.proxy_for_type, filter: { processing_state: criteria.processing_state }
        )
      end

      def work_access_right_codes(work:)
        work.access_rights.pluck(:access_right_code)
      end
    end
  end
end
