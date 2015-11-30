module Sipity
  # :nodoc:
  module Queries
    # Queries
    module RedirectQueries
      # Responsible for querying for the existence of the most current redirect
      #
      # @param work [Sipity::Models::Work]
      # @param as_of [Date]
      def active_redirect_for(work:, as_of: Time.zone.today)
        work = Conversions::ConvertToWork.call(work)
        Sipity::Models::WorkRedirectStrategy.includes(work: { work_submission: :work_area }).where(
          work_id: work.id
        ).where('start_date <= :as_of AND (end_date IS NULL OR end_date > :as_of)', as_of: as_of).order('start_date ASC').first
      end
    end
  end
end
