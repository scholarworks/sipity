module Sipity
  # :nodoc:
  module Commands
    # Commands
    module RedirectCommands
      # Responsible for creating and managing the temporal nature of redirects for a given work.
      #
      # @param work [Sipity::Models::Work]
      # @param url [String]
      # @param as_of [Date]
      def create_redirect_for(work:, url:, as_of: Time.zone.today)
        work = Conversions::ConvertToWork.call(work)
        update_previous_open_ended_redirects_for(work: work, as_of: as_of)
        upcoming_start_date = Sipity::Models::WorkRedirectStrategy.where(
          work_id: work.id
        ).where('start_date > :start_date', start_date: as_of).order('start_date ASC').pluck(:start_date).first
        Sipity::Models::WorkRedirectStrategy.create!(work_id: work.id, url: url, start_date: as_of, end_date: upcoming_start_date)
      end

      private

      def update_previous_open_ended_redirects_for(work:, as_of:)
        previous_open_ended_redirect = Sipity::Models::WorkRedirectStrategy.where(
          end_date: nil, work_id: work.id
        ).where('start_date < :start_date', start_date: as_of).order('start_date DESC').first
        previous_open_ended_redirect.update_attribute(:end_date, as_of) if previous_open_ended_redirect
      end
    end
  end
end
