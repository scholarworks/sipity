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
        let(:cogitate_data) { { cogitate: :data } }
        before { allow(Cogitate::Client).to receive(:retrieve_data_from).with(ticket: ticket).and_return(cogitate_data) }

        it 'will retrieve an agent from a ticket' do
          expect(Cogitate::Client).to receive(:retrieve_data_from).with(ticket: ticket).and_return(cogitate_data)
          get :create, ticket: ticket
        end

        it 'will set the :cogitate_data session' do
          get :create, ticket: ticket
          expect(session[:cogitate_data]).to eq(cogitate_data)
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

      context 'DELETE :destroy' do
        it 'will remove session information' do
          controller.session[:cogitate_data] = 'hello'
          delete :destroy
          expect(controller.session).to be_empty
          expect(response).to redirect_to('/')
        end
      end

      context 'GET :mock_new' do
        it 'will build a new mock agent for rendering' do
          get :mock_new, mock_agent: { email: 'hello@world.com' }
          expect(assigns(:mock_agent)).to respond_to(:to_cogitate_data)
        end

        it 'will render the mock_new form' do
          get :mock_new, mock_agent: { email: 'hello@world.com' }
          expect(response).to render_template('mock_new')
        end

        it 'will set the before_authentication_location if a referer is given' do
          controller.request.env['HTTP_REFERER'] = 'http://hello.world.com'
          expect { get :mock_new }.to change { controller.session[:before_authentication_location] }.to('http://hello.world.com')
        end
      end

      context 'POST :mock_create' do
        context 'with valid data' do
          let(:valid_parameters) { { email: 'hello@world.com', strategy: 'NetID', identifying_value: 'hworld' } }
          before do
            expect_any_instance_of(Sipity::Models::MockAgent).to receive(:valid?).and_return(true)
            expect_any_instance_of(Sipity::Models::MockAgent).to receive(:to_cogitate_data).and_return('valid_cogitate_data')
          end

          it 'will set the :cogitate_data session' do
            post :mock_create, mock_agent: valid_parameters
            expect(session[:cogitate_data]).to eq('valid_cogitate_data')
          end

          it 'will redirect to the before_authentication_location if one exists' do
            controller.session[:before_authentication_location] = 'http://hello.world.com'
            post :mock_create, mock_agent: valid_parameters
            expect(response).to redirect_to('http://hello.world.com')
          end

          it 'will redirect to the index if before_authentication_location was NOT set' do
            post :mock_create, mock_agent: valid_parameters
            expect(response).to redirect_to('/')
          end
        end

        context 'with invalid data' do
          let(:invalid_parameters) { { email: 'hello@world.com', strategy: '', identifying_value: '' } }
          before do
            expect_any_instance_of(Sipity::Models::MockAgent).to receive(:valid?).and_return(false)
          end

          it 'will not set the :cogitate_data session' do
            post :mock_create, mock_agent: invalid_parameters
            expect(session[:cogitate_data]).to be_nil
          end

          it 'will have an unprocessible entity status' do
            post :mock_create, mock_agent: invalid_parameters
            expect(response.status).to eq(422)
          end

          it 'will render the an unprocessible entity status' do
            post :mock_create, mock_agent: invalid_parameters
            expect(response).to render_template('mock_new')
          end
        end
      end
    end
  end
end
