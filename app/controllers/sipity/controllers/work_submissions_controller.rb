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
          processing_action_name: query_action_name,
          attributes: query_or_command_attributes
        )

        # I could use action instead of template, but I feel the explicit path
        # for template is better than the implicit pathing of :action
        handle_response(runner_response, template: "sipity/controllers/work_submissions/#{query_action_name}")
      end

      def command_action
        runner_response = run(
          work_id: work_id,
          processing_action_name: command_action_name,
          attributes: query_or_command_attributes
        )

        # I could use action instead of template, but I feel the explicit path
        # for template is better than the implicit pathing of :action
        handle_response(runner_response, template: "sipity/controllers/work_submissions/#{command_action_name}")
      end

      attr_accessor :view_object
      helper_method :view_object

      private

      def work_id
        params.require(:work_id)
      end

      def query_action_name
        params.require(:query_action_name)
      end

      def command_action_name
        params.require(:command_action_name)
      end

      def query_or_command_attributes
        params.fetch(:work) { HashWithIndifferentAccess.new }
      end

      def handle_response(handled_response, template:)
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
