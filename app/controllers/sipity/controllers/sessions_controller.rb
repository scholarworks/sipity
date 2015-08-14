require 'cogitate/client/retrieve_agent_from_ticket'

module Sipity
  module Controllers
    # Responsible for coordinating with Cogitate regarding user authentication
    class SessionsController < ApplicationController
      def new
        session[:before_authentication_location] = request.referer if request.referer
        redirect_to Cogitate.configuration.url_for_authentication
      end

      def create
        # Convert the Ticket into an Agent
        # Sessionize the Agent
        # Redirect to the appropriate location
        agent = Cogitate::Client::RetrieveAgentFromTicket.call(ticket: params.fetch(:ticket))
        session[:agent] = agent.as_json
        before_authentication_location = session.delete(:before_authentication_location)
        if before_authentication_location
          redirect_to before_authentication_location
        else
          redirect_to '/'
        end
      end
    end
  end
end
