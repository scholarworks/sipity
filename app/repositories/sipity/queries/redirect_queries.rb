module Sipity
  # :nodoc:
  module Queries
    # Queries
    module RedirectQueries
      # Responsible for querying for the existence of the most current redirect
      #
      # @param work_id [Sipity::Models::Work#id]
      # @param as_of [Date]
      def active_redirect_for(work_id:, as_of: Time.zone.today)
        Sipity::Models::WorkRedirectStrategy.includes(work: { work_submission: :work_area }).where(
          work_id: work_id
        ).where('start_date <= :as_of AND (end_date IS NULL OR end_date > :as_of)', as_of: as_of).order('start_date ASC').first
      end
    end
  end
end
