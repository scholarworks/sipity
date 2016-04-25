module Sipity
  module Controllers
    # Controller responsible for rendering a user's dashboard. That is to say
    # How can I see everything?
    class DashboardsController < AuthenticatedController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::DashboardRunners

      def index
        _status, @view = run(processing_state: processing_state, page: params[:page])
        respond_with(@view)
      end
      attr_reader :view
      helper_method :view

      private

      def processing_state
        params[:processing_state]
      end
    end
  end
end
