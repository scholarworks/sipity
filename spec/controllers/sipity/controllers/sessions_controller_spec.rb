require 'rails_helper'

module Sipity
  module Controllers
    RSpec.describe SessionsController, type: :controller do
      context 'GET :new' do
        it 'will redirect to the Cogitate configuration url_for_authorization' do
          get :new
          expect(response).to redirect_to(Cogitate.configuration.url_for_authentication)
        end
      end

      context 'GET :create' do
        let(:ticket) { '123-456' }
        let(:agent) { { 'hello' => 'world' } }
        it 'will redirect to the Cogitate configuration url_for_authorization' do
          expect(Cogitate::Client::RetrieveAgentFromTicket).to receive(:call).with(ticket: ticket).and_return(agent)
          get :create, ticket: ticket
        end
      end
    end
  end
end
