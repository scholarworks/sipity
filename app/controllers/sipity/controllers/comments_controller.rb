module Sipity
  module Controllers
    # Controller for displaying comments
    class CommentsController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::CommentRunners

      def index
        status, model = run(work_id: work_id)
        with_authentication_hack_to_remove_warden(status) do
          @model = Decorators::WorkDecorator.decorate(model)
          respond_with(@model)
        end
      end

      private

      def work_id
        params.require(:work_id)
      end
    end
  end
end
