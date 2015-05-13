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
        run_and_respond_with_processing_action(work_area_slug: work_area_slug, attributes: query_or_command_attributes)
      end

      def command_action
        run_and_respond_with_processing_action(work_area_slug: work_area_slug, attributes: query_or_command_attributes)
      end

      def initialize(*args, &block)
        super(*args, &block)
        self.processing_action_composer = ProcessingActionComposer.new(controller: self)
      end

      delegate(
        :prepend_processing_action_view_path_with,
        :run_and_respond_with_processing_action,
        to: :processing_action_composer
      )

      attr_accessor :view_object
      helper_method :view_object

      private

      attr_accessor :processing_action_composer

      def work_area_slug
        params.require(:work_area_slug)
      end

      def query_or_command_attributes
        params.fetch(:work_area) { HashWithIndifferentAccess.new }
      end
    end
  end
end
