module Sipity
  module Controllers
    # The controller for creating works.
    class WorkSubmissionsController < ApplicationController
      class_attribute :response_handler_container
      self.runner_container = Sipity::Runners::WorkSubmissionsRunners
      self.response_handler_container = Sipity::ResponseHandlers::WorkSubmissionHandler

      def query_action
        runner_response = run(
          work_id: work_id,
          processing_action_name: processing_action_name,
          attributes: query_or_command_attributes
        )
        handle_response(runner_response)
      end

      def command_action
        runner_response = run(
          work_id: work_id,
          processing_action_name: processing_action_name,
          attributes: query_or_command_attributes
        )
        handle_response(runner_response)
      end

      attr_accessor :view_object
      helper_method :view_object
      alias_method :model, :view_object
      helper_method :model

      private

      def work_id
        params.require(:work_id)
      end

      def processing_action_name
        params.require(:processing_action_name)
      end

      def query_or_command_attributes
        params.fetch(:work) { HashWithIndifferentAccess.new }
      end

      def handle_response(handled_response)
        Sipity::ResponseHandlers.handle_response(
          context: self,
          handled_response: handled_response,
          container: response_handler_container
        )
      end

      def run(*args)
        # TODO: This is an intermediary step that will be wrapped into the
        #   existing #run method; However it should be considered experimental
        status, object = super(*args)
        Parameters::HandledResponseParameter.new(
          status: status, object: object, template: "sipity/controllers/work_submissions/#{processing_action_name}"
        )
      end
    end
  end
end
