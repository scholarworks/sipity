require 'cogitate/client/retrieve_agent_from_ticket'

module Sipity
  module Controllers
    # Responsible for coordinating with Cogitate regarding user authentication
    class SessionsController < ApplicationController
      def new
        redirect_to Cogitate.configuration.url_for_authentication
      end

      def create
        # Convert the Ticket into an Agent
        # Sessionize the Agent
        # Redirect to the appropriate location
        agent = Cogitate::Client::RetrieveAgentFromTicket.call(ticket: params.fetch(:ticket))
        render json: agent.as_json, format: :json
      end
    end
  end
end
