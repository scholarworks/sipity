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

      def build_dashboard_view(user:, filter: {})
        Decorators::DashboardView.new(repository: self, user: user, filter: filter)
      end

      # TODO: Rename this method; Keeping it separate for now.
      def build_work_submission_processing_action_form(work:, processing_action_name:, attributes: {})
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::WorkSubmissions.build_the_form(
          work: work,
          processing_action_name: processing_action_name,
          attributes: attributes,
          repository: self
        )
      end

      def find_works_for(user:, processing_state: nil)
        Policies::WorkPolicy::Scope.resolve(user: user, scope: Models::Work, processing_state: processing_state)
      end

      def work_access_right_codes(work:)
        work.access_rights.pluck(:access_right_code)
      end

      def build_create_work_form(attributes: {})
        Forms::Etd::StartASubmissionForm.new(attributes.merge(repository: self))
      end
    end
  end
end
