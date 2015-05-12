module Sipity
  module Controllers
    # Responsible for presenting current comments
    class CurrentCommentsPresenter < Curly::Presenter
      presents :current_comments

      def path_to_all_comments
        # TODO: Fix this to be the general case.
        work_comments_path(current_comments.entity)
      end

      delegate :comments, to: :current_comments

      private

      attr_reader :current_comments
    end
  end
end
