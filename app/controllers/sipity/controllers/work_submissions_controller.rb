require_relative '../controllers'
require_relative './processing_action_composer'

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

      # Obliterating view paths because the processing action composer insists
      # that it handles view paths.
      def initialize(*args, &block)
        super(*args, &block)
        self.processing_action_composer = ProcessingActionComposer.new(controller: self)
      end

      delegate(
        :prepend_processing_action_view_path_with,
        :handle_response,
        :processing_action_name,
        to: :processing_action_composer
      )

      attr_accessor :view_object
      helper_method :view_object
      alias_method :model, :view_object
      helper_method :model

      private

      attr_accessor :processing_action_composer

      def work_id
        params.require(:work_id)
      end

      def query_or_command_attributes
        params.fetch(:work) { HashWithIndifferentAccess.new }
      end

      def run(*args)
        # TODO: This is an intermediary step that will be wrapped into the
        #   existing #run method; However it should be considered experimental
        status, object = super(*args)
        Parameters::HandledResponseParameter.new(
          status: status, object: object, template: processing_action_name
        )
      end
    end
  end
end
