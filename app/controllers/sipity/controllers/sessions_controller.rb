require 'cogitate/client'
require 'sipity/models/mock_agent'

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
        successful_create
      end

      def destroy
        reset_session
        redirect_to '/'
      end

      # Why is mock_new and mock_create in this controller? Because I am interested in keeping some of
      # the business logic in close proximity.
      def mock_new
        session[:before_authentication_location] = request.referer if request.referer
        @mock_agent = Models::MockAgent.new(attributes: mock_agent_params)
      end

      def mock_create
        @mock_agent = Models::MockAgent.new(attributes: mock_agent_params)
        if @mock_agent.valid?
          session[:cogitate_data] = @mock_agent.to_cogitate_data
          successful_create
        else
          render 'mock_new', status: :unprocessable_entity
        end
      end

      private

      def successful_create
        before_authentication_location = session.delete(:before_authentication_location)
        redirect_to(before_authentication_location || '/')
      end

      def mock_agent_params
        params.fetch(:mock_agent) { {} }
      end
    end
  end
end
