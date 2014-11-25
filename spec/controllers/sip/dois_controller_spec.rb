require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sip
  RSpec.describe DoisController, type: :controller do
    let(:header) { double(title: 'The Title', to_param: '1234') }

    context 'GET #show' do
      before { controller.runner = runner }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: header,
          callback_name: callback_name,
          run_with: { header_id: header.to_param },
          context: controller
        )
      end

      context 'when :doi_not_assigned' do
        let(:callback_name) { :doi_not_assigned }
        it 'will render the show page' do
          get 'show', header_id: header.to_param
          expect(flash[:alert]).to_not be_empty
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('doi_not_assigned')
        end
      end

      context 'when :doi_already_assigned' do
        let(:callback_name) { :doi_already_assigned }
        it 'will redirect to the header page' do
          get 'show', header_id: header.to_param
          expect(flash[:notice]).to_not be_empty
          expect(assigns(:model)).to be_nil
          expect(response).to redirect_to sip_header_path(header.to_param)
        end
      end
    end

    context 'POST #assign' do
      before { controller.runner = runner }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: [header, identifier],
          callback_name: callback_name,
          run_with: { header_id: header.to_param, identifier: identifier },
          context: controller
        )
      end

      context 'when :success' do
        let(:callback_name) { :success }
        let(:identifier) { 'doi:abc' }
        it 'will redirect to the sip header path' do
          post 'assign', header_id: header.to_param, doi: { identifier: identifier }
          expect(flash[:notice]).to_not be_empty
          expect(response).to redirect_to(sip_header_path(header.to_param))
        end
      end

      context 'when :failure' do
        let(:identifier) { 'doi:abc' }
        let(:callback_name) { :failure }
        it 'will render the show page' do
          post 'assign', header_id: header.to_param, doi: { identifier: identifier }
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('assign')
        end
      end
    end
  end
end
