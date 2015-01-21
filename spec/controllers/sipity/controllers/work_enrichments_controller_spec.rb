require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe WorkEnrichmentsController, type: :controller do
      let(:work) { double('Work', persisted?: true, title: 'Hello World') }
      let(:enrichment_type) { 'describe' }
      context 'GET #edit' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yielded_object, callback_name: callback_name, context: controller,
            run_with: { enrichment_type: enrichment_type, work_id: work.to_param }
          )
        end
        let(:yielded_object) { work }
        let(:callback_name) { :success }
        it 'will render the edit page' do
          get 'edit', work_id: work.to_param, enrichment_type: enrichment_type
          expect(assigns(:model)).to_not be_nil
        end
      end
      context 'POST #update' do
        let(:attributes) { { 'hello' => 'world' } }
        let(:callback_name) { :success }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yielded_object, callback_name: callback_name, context: controller,
            run_with: { enrichment_type: enrichment_type, work_id: work.to_param, attributes: attributes }
          )
        end
        before { controller.runner = runner }
        context 'on success' do
          let(:callback_name) { :success }
          let(:yielded_object) { work }
          it 'will redirect to the work' do
            post 'update', work_id: work.to_param, enrichment_type: enrichment_type, work: attributes
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
            post 'update', work_id: work.to_param, enrichment_type: enrichment_type, work: attributes
            expect(assigns(:model)).to be_present
            expect(response).to render_template(enrichment_type)
          end
        end
      end
    end
  end
end
