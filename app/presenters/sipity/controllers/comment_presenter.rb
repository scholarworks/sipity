module Sipity
  module Controllers
    # Responsible for presenting a comment.
    class CommentPresenter < Curly::Presenter
      presents :comment

      delegate :name_of_commentor, to: :comment

      def message
        comment.comment
      end

      private

      attr_reader :comment
    end
  end
end
