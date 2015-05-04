module Sipity
  module Controllers
    # Responsible for presenting a SubmissionWindow
    class SubmissionWindowPresenter < Curly::Presenter
      presents :submission_window

      delegate :slug, to: :@submission_window, prefix: :submission_window
    end
  end
end
