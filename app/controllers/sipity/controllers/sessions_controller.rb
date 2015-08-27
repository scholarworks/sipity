require 'cogitate/client/ticket_to_token_coercer'

module Sipity
  module Controllers
    # Responsible for coordinating with Cogitate regarding user authentication
    class SessionsController < ApplicationController
      def new
        session[:before_authentication_location] = request.referer if request.referer
        redirect_to Cogitate.configuration.url_for_authentication
      end

      def create
        # TODO: Switch to the immediate following line
        # Sipity::Services::AuthenticationLayer.receive_cogitate_ticket(ticket: params.fetch(:ticket))
        session[:cogitate_token] = Cogitate::Client::TicketToTokenCoercer.call(ticket: params.fetch(:ticket))
        before_authentication_location = session.delete(:before_authentication_location)
        redirect_to(before_authentication_location || '/')
      end
    end
  end
end
