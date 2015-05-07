module Sipity
  module Controllers
    # Responsible for handling an HTTP request to interact with a WorkArea.
    #
    # @note This is part of the Sipity::ResponseHandlers experimentation.
    class WorkAreasController < ApplicationController
      class_attribute :response_handler_container
      self.runner_container = Sipity::Runners::WorkAreaRunners
      self.response_handler_container = Sipity::ResponseHandlers::WorkAreaHandler

      def query_action
        runner_response = run(
          work_area_slug: work_area_slug,
          processing_action_name: processing_action_name,
          attributes: query_or_command_attributes
        )

        # I could use action instead of template, but I feel the explicit path
        # for template is better than the implicit pathing of :action
        handle_response(runner_response, template: "sipity/controllers/work_areas/#{processing_action_name}")
      end

      def command_action
        runner_response = run(
          work_area_slug: work_area_slug,
          processing_action_name: processing_action_name,
          attributes: query_or_command_attributes
        )

        # I could use action instead of template, but I feel the explicit path
        # for template is better than the implicit pathing of :action
        handle_response(runner_response, template: "sipity/controllers/work_areas/#{processing_action_name}")
      end

      attr_accessor :view_object
      helper_method :view_object

      private

      def work_area_slug
        params.require(:work_area_slug)
      end

      def processing_action_name
        params.require(:processing_action_name)
      end

      def query_or_command_attributes
        params.fetch(:work_area) { HashWithIndifferentAccess.new }
      end

      def handle_response(handled_response, template:  "sipity/controllers/work_areas/#{action_name}")
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
