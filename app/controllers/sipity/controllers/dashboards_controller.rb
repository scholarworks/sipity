module Sipity
  module Controllers
    # Controller responsible for rendering a user's dashboard. That is to say
    # How can I see everything?
    class DashboardsController < ApplicationController
      respond_to :html, :json

      def index
        # TODO: Extract the runner
        @view = repository.find_works_for(user: current_user, processing_state: processing_state)
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
