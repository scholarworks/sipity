module Sipity
  module Controllers
    # Responsible for handling an HTTP request to interact with a WorkArea.
    #
    # @note This is part of the Sipity::ResponseHandlers experimentation.
    class SubmissionWindowsController < ApplicationController
      class_attribute :response_handler_container
      self.runner_container = Sipity::Runners::SubmissionWindowRunners
      self.response_handler_container = Sipity::ResponseHandlers::SubmissionWindowHandler

      def show
        runner_response = run(work_area_slug: work_area_slug, submission_window_slug: submission_window_slug)
        handle_response(runner_response)
      end

      attr_accessor :view_object
      helper_method :view_object

      private

      def work_area_slug
        params.require(:work_area_slug)
      end

      def submission_window_slug
        params.require(:submission_window_slug)
      end

      def handle_response(handled_response, template:  "sipity/controllers/submission_windows/#{action_name}")
        Sipity::ResponseHandlers.handle_response(
          context: self,
          handled_response: handled_response,
          container: response_handler_container,
          template: template
        )
      end

      def run(*args)
        # TODO: This is an intermediary step that will be wrapped into the
        #   existing #run method; However it should be considered experimental
        status, object = super(*args)
        Parameters::HandledResponseParameter.new(status: status, object: object)
      end
    end
  end
end
