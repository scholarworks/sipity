module Sipity
  module Controllers
    # Controller responsible for rendering a user's dashboard. That is to say
    # How can I see everything?
    class DashboardsController < ApplicationController
      respond_to :html, :json

      self.runner_container = Sipity::Runners::DashboardRunners

      def index
        status, @view = run(processing_state: processing_state, page: params[:page])
        with_authentication_hack_to_remove_warden(status) { respond_with(@view) }
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
