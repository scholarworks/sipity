require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe AccountProfilesController, type: :controller do

      let(:user) { double('User') }
      context 'GET #edit' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { attributes: attributes }, context: controller
          )
        end
        let(:attributes) { { "preferred_name" => 'bogus' } }
        let(:yields) { user }
        let(:callback_name) { :success }
        it 'will render the edit page' do
          get 'edit', user: attributes
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('edit')
        end
      end

      context 'POST #update' do
        let(:callback_name) { :success }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
              yields: yields, callback_name: callback_name, run_with: { attributes: attributes }, context: controller
          )
        end
        let(:attributes) { { 'preferred_name' => 'bogus' } }
        before { controller.runner = runner }
        context 'on success' do
          let(:callback_name) { :success }
          let(:yields) { user }
          it 'will redirect to the account profile page' do
            post 'update', user: attributes
            expect(flash[:notice]).to_not be_empty
            expect(assigns(:model)).to be_nil
          end
        end
        context 'on failure' do
          let(:form) { double('Form') }
          let(:callback_name) { :failure }
          let(:yields) { form }
          it 'will render the work again' do
            post 'update', user: attributes
            expect(assigns(:model)).to be_present
            expect(response).to render_template('edit')
          end
        end
      end
    end
  end
end
