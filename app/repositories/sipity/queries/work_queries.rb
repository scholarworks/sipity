module Sipity
  module Queries
    # Queries
    module WorkQueries
      BASE_HEADER_ATTRIBUTES = [:title, :work_publication_strategy].freeze
      def find_work(work_id)
        Models::Work.includes(:processing_entity, work_submission: [:work_area, :submission_window]).find(work_id)
      end

      def build_dashboard_view(user:, filter: {})
        Decorators::DashboardView.new(repository: self, user: user, filter: filter)
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
