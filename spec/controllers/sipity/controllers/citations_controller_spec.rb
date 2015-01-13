require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe CitationsController, type: :controller do
      let(:work) { Models::Sip.new(title: 'The Title', id: '1234') }

      context 'GET #show' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { work_id: work.to_param }, context: controller
          )
        end

        context 'when :citation_not_assigned' do
          let(:yields) { work }
          let(:callback_name) { :citation_not_assigned }
          it 'will redirect to the edit page' do
            get 'show', work_id: work.to_param
            # expect(flash[:alert]).to_not be_empty
            expect(response).to redirect_to(new_work_citation_path(work))
          end
        end

        context 'when :citation_assigned' do
          let(:yields) { work }
          let(:callback_name) { :citation_assigned }
          it 'will render the show page' do
            get 'show', work_id: work.to_param
            expect(assigns(:model)).to_not be_nil
            expect(response).to render_template('show')
          end
        end
      end

      context 'GET #new' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { work_id: work.to_param }, context: controller
          )
        end

        context 'when :citation_not_assigned' do
          let(:yields) { work }
          let(:callback_name) { :citation_not_assigned }
          it 'will render the new page' do
            get 'new', work_id: work.to_param
            expect(assigns(:model)).to_not be_nil
            expect(response).to render_template('new')
          end
        end

        context 'when :citation_assigned' do
          let(:yields) { work }
          let(:callback_name) { :citation_assigned }
          it 'will redirect to the show page' do
            get 'new', work_id: work.to_param
            expect(flash[:notice]).to_not be_empty
            expect(assigns(:model)).to be_nil
            expect(response).to redirect_to(work_citation_path(work))
          end
        end
      end

      context 'POST #create' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, context: controller,
            run_with: { work_id: work.to_param, attributes: attributes }
          )
        end
        let(:attributes) { { 'key' => 'value' } }

        context 'when :success' do
          let(:yields) { work }
          let(:callback_name) { :success }
          it 'will redirect to the work page' do
            post 'create', work_id: work.to_param, citation: attributes
            expect(flash[:notice]).to_not be_empty
            expect(assigns(:model)).to be_nil
            expect(response).to redirect_to(work_path(work))
          end
        end

        context 'when :failure' do
          let(:yields) { work }
          let(:callback_name) { :failure }
          it 'will render the "new" template' do
            # A dirty shim acknowledging the terse, yit fickle, respond_with
            # methodology.
            allow(work).to receive(:errors).and_return([:yes])
            post 'create', work_id: work.to_param, citation: attributes
            expect(assigns(:model)).to_not be_nil
            expect(response).to render_template('new')
          end
        end
      end
    end
  end
end
