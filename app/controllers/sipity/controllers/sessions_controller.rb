require 'cogitate/client'

module Sipity
  module Controllers
    # Responsible for coordinating with Cogitate regarding user authentication
    class SessionsController < ApplicationController
      def new
        session[:before_authentication_location] = request.referer if request.referer
        redirect_to Cogitate.configuration.url_for_authentication
      end

      def create
        session[:cogitate_data] = Cogitate::Client.retrieve_data_from(ticket: params.fetch(:ticket))
        before_authentication_location = session.delete(:before_authentication_location)
        redirect_to(before_authentication_location || '/')
      end
    end
  end
end
