require 'rails_helper'

module Sipity
  module Controllers
    RSpec.describe SessionsController, type: :controller do
      context 'GET :new' do
        it 'will redirect to the Cogitate configuration url_for_authorization' do
          get :new
          expect(response).to redirect_to(Cogitate.configuration.url_for_authentication)
        end

        it 'will set the before_authentication_location if a referer is given' do
          controller.request.env['HTTP_REFERER'] = 'http://hello.world.com'
          expect { get :new }.to change { controller.session[:before_authentication_location] }.to('http://hello.world.com')
        end
      end

      context 'GET :create' do
        let(:ticket) { '123-456' }
        let(:cogitate_token) { 'The Token' }
        before { allow(Cogitate::Client::TicketToTokenCoercer).to receive(:call).with(ticket: ticket).and_return(cogitate_token) }

        it 'will retrieve an agent from a ticket' do
          expect(Cogitate::Client::TicketToTokenCoercer).to receive(:call).with(ticket: ticket).and_return(cogitate_token)
          get :create, ticket: ticket
        end

        it 'will set the :cogitate_token session' do
          get :create, ticket: ticket
          expect(session[:cogitate_token]).to eq(cogitate_token)
        end

        it 'will redirect to the before_authentication_location if one exists' do
          controller.session[:before_authentication_location] = 'http://hello.world.com'
          get :create, ticket: ticket
          expect(response).to redirect_to('http://hello.world.com')
        end

        it 'will redirect to the index if before_authentication_location was NOT set' do
          get :create, ticket: ticket
          expect(response).to redirect_to('/')
        end
      end
    end
  end
end
