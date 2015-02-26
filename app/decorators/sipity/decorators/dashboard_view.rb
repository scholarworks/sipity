module Sipity
  module Decorators
    # Responsible for collecting the logic related to rendering a user's
    # dashboard.
    class DashboardView
      def initialize(repository: default_repository, user:, filter: {})
        @repository = repository
        @filter = filter
        @user = user
      end

      attr_reader :repository, :user, :filter
      private :repository, :user, :filter

      def search_path
        view_context.dashboard_path
      end

      def filterable_processing_states
        # TODO: Move this to a repository question; After all don't we want
        # to limit the filter to only objects that are for states in which the
        # user can actually do something (ie see it, alter it, etc)
        Models::Processing::StrategyState.all.pluck(:name).uniq.sort
      end

      def works
        repository.find_works_for(user: user, processing_state: processing_state)
      end

      def each
        works.each { |work| yield(work) }
      end
      deprecate :each

      def processing_state
        filter[:processing_state]
      end

      private

      def view_context
        Draper::ViewContext.current
      end

      def default_repository
        QueryRepository.new
      end
    end
  end
end
