require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe WorkEventTriggersController, type: :controller do
      let(:work) { double('Work', persisted?: true, title: 'Hello World') }
      let(:processing_action_name) { 'submit_for_review' }
      context 'GET #new' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yielded_object, callback_name: callback_name, context: controller,
            run_with: { processing_action_name: processing_action_name, work_id: work.to_param }
          )
        end
        let(:yielded_object) { work }
        let(:callback_name) { :success }
        it 'will render the new page' do
          get 'new', work_id: work.to_param, processing_action_name: processing_action_name
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('new')
        end
      end

      context 'POST #create' do
        let(:attributes) { { 'hello' => 'world' } }
        let(:callback_name) { :success }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yielded_object, callback_name: callback_name, context: controller,
            run_with: { processing_action_name: processing_action_name, work_id: work.to_param }
          )
        end
        before { controller.runner = runner }
        context 'on success' do
          let(:callback_name) { :success }
          let(:yielded_object) { work }
          it 'will redirect to the work' do
            post 'create', work_id: work.to_param, processing_action_name: processing_action_name
            expect(flash[:notice]).to_not be_empty
            expect(assigns(:model)).to be_nil
            expect(response).to redirect_to work_path(work.to_param)
          end
        end
        context 'on failure' do
          let(:form) { double('Form') }
          let(:callback_name) { :failure }
          let(:yielded_object) { form }
          it 'will render the work again' do
            post 'create', work_id: work.to_param, processing_action_name: processing_action_name
            expect(assigns(:model)).to be_present
            expect(response).to render_template('new')
          end
        end
      end
    end
  end
end
