module Sipity
  module Controllers
    # Controller for displaying comments
    class CommentsController < AuthenticatedController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::CommentRunners

      def index
        _status, model = run(work_id: work_id)
        @model = Decorators::WorkDecorator.decorate(model)
        respond_with(@model)
      end

      private

      def work_id
        params.require(:work_id)
      end
    end
  end
end
