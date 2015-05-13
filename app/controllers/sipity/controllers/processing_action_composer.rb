module Sipity
  module Controllers
    # Responsible for composing collaborating behavior on the base controller.
    class ProcessingActionComposer
      def initialize(controller:)
        self.controller = controller
      end

      delegate :prepend_view_path, :params, :response_handler_container, to: :controller

      def prepend_processing_action_view_path_with(slug:)
        path = build_processing_action_view_path_for(slug: slug)
        controller.prepend_view_path(path)
      end

      def processing_action_name
        params.fetch(:processing_action_name)
      end

      def handle_response(handled_response)
        Sipity::ResponseHandlers.handle_response(
          context: controller,
          handled_response: handled_response,
          container: response_handler_container
        )
      end

      private

      # TODO: I should guard the methods
      attr_accessor :controller

      ROOT_VIEW_PATH = Rails.root.join('app/views/sipity/controllers').freeze

      def build_processing_action_view_path_for(slug:)
        # TODO: Why work_submissions?
        File.join(ROOT_VIEW_PATH, 'work_submissions', PowerConverter.convert_to_file_system_safe_file_name(slug))
      end
    end
  end
end
