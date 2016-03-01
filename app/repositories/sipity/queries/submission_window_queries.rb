module Sipity
  module Queries
    # Queries related to SubmissionWindows.
    module SubmissionWindowQueries
      def find_submission_window_by(slug:, work_area:)
        work_area = PowerConverter.convert_to_work_area(work_area)
        Models::SubmissionWindow.find_by!(slug: slug, work_area_id: work_area.id)
      end

      # @api public
      #
      # @param work_area [#to_work_area]
      # @param as_of [Time]
      # @return ActiveRecord::Relation records from Models::SubmissionWindow
      #
      # @note This query shares logic with OpenForStartingSubmissionsValidator#validate_each
      # @todo This query does not check if the user has permission to take the "start_a_submission" action
      #       within the given submission window. In part, the challenge is that the start_a_submission action
      #       is available to any authenticated user; To reflect this behavior I would need to further expand the queries
      #       to treat a visitor as the "any authenticated user" for this context only.
      #
      # @see OpenForStartingSubmissionsValidator
      def find_open_submission_windows_by(work_area:, as_of: Time.zone.now)
        work_area = PowerConverter.convert_to_work_area(work_area)
        submission_windows = Models::SubmissionWindow.arel_table
        processing_entities = Models::Processing::Entity.arel_table
        processing_states = Models::Processing::StrategyState.arel_table
        Models::SubmissionWindow.order(:slug).where(work_area_id: work_area.id).where(
          submission_windows[:id].in(
            processing_entities.project(processing_entities[:proxy_for_id]).join(processing_states).on(
              processing_entities[:strategy_state_id].eq(processing_states[:id])
            ).where(
              processing_entities[:proxy_for_type].eq(Conversions::ConvertToPolymorphicType.call(Models::SubmissionWindow)).and(
                processing_states[:name].eq(Models::Processing::StrategyState::OPEN_SUBMISSION_WINDOW_STATE)
              )
            )
          )
        )
      end

      def build_submission_window_processing_action_form(submission_window:, processing_action_name:, **keywords)
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::SubmissionWindows.build_the_form(
          submission_window: submission_window,
          processing_action_name: processing_action_name,
          repository: self,
          **keywords
        )
      end
    end
  end
end
