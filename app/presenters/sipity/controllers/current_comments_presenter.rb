module Sipity
  module Controllers
    # Responsible for presenting current comments
    class CurrentCommentsPresenter < Curly::Presenter
      presents :current_comments

      def path_to_all_comments
        work_comments_path(work_id: current_comments.entity)
      end

      delegate :comments, to: :current_comments

      private

      attr_reader :current_comments
    end
  end
end
