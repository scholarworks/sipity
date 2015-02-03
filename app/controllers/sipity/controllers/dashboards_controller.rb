module Sipity
  module Controllers
    # Controller responsible for rendering a user's dashboard. That is to say
    # How can I see everything?
    class DashboardsController < ApplicationController
      respond_to :html, :json

      def index
        @view = repository.find_works_for(user: current_user)
        respond_with(@view)
      end
      attr_reader :view
      helper_method :view
    end
  end
end
