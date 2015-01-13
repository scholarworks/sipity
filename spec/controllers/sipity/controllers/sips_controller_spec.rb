require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe SipsController, type: :controller do
      let(:sip) { Models::Sip.new(title: 'The Title', id: '1234') }

      context 'GET #new' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { attributes: attributes }, context: controller
          )
        end
        let(:attributes) { { 'title' => 'My Title' } }
        let(:yields) { sip }
        let(:callback_name) { :success }
        it 'will render the new page' do
          get 'new', sip: attributes
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('new')
        end
      end

      context 'POST #create' do
        before do
          controller.runner = runner
          # Because Rails checks persisted for when processing respond_with
          allow(sip).to receive(:persisted?).and_return(true)
        end
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { attributes: attributes }, context: controller
          )
        end
        let(:attributes) { { 'title' => 'My Title' } }
        let(:yields) { sip }
        let(:callback_name) { :success }
        it 'will render the new page' do
          post 'create', sip: attributes
          expect(assigns(:model)).to_not be_nil
          expect(response).to redirect_to("/sips/#{sip.to_param}")
        end
      end

      context 'GET #edit' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { sip_id: sip.to_param }, context: controller
          )
        end

        let(:yields) { sip }
        let(:callback_name) { :success }
        it 'will render the edit page' do
          get 'edit', id: sip.to_param
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('edit')
        end
      end

      context 'PUT #create' do
        before do
          controller.runner = runner
          # Because Rails checks persisted for when processing respond_with
          allow(sip).to receive(:persisted?).and_return(true)
        end
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name,
            run_with: { sip_id: sip.to_param, attributes: attributes }, context: controller
          )
        end
        let(:attributes) { { 'title' => 'My Title' } }
        let(:yields) { sip }
        let(:callback_name) { :success }
        it 'will render the new page' do
          put 'update', id: sip.to_param, sip: attributes
          expect(assigns(:model)).to_not be_nil
          expect(response).to redirect_to("/sips/#{sip.to_param}")
        end
      end
      context 'GET #show' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { sip_id: sip.to_param }, context: controller
          )
        end

        let(:yields) { sip }
        let(:callback_name) { :success }
        it 'will render the show page' do
          get 'show', id: sip.to_param
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('show')
        end
      end

    end
  end
end
