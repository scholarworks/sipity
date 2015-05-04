module Sipity
  module Controllers
    # Responsible for presenting a SubmissionWindow
    class SubmissionWindowPresenter < Curly::Presenter
      presents :submission_window

      def initialize(context, options = {})
        # Because controller actions may not cooperate and instead set a
        # :view_object.
        options['submission_window'] ||= options['view_object']
        super
        self.processing_actions = compose_processing_actions
      end

      delegate :work_area, :work_area_slug, :slug, to: :submission_window

      attr_reader :submission_window
      private :submission_window, :work_area

      def link
        link_to(slug, path)
      end

      def path
        submission_window_for_work_area_path(work_area_slug: work_area_slug, submission_window_slug: slug)
      end

      delegate(
        :resourceful_actions, :resourceful_actions?,
        :enrichment_actions, :enrichment_actions?,
        :state_advancing_actions, :state_advancing_actions?,
        to: :processing_actions
      )

      private

      attr_accessor :processing_actions

      def compose_processing_actions
        ComposableElements::ProcessingActionsComposer.new(user: current_user, entity: work_area)
      end
    end
  end
end
