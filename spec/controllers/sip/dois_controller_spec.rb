require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  RSpec.describe DoisController, type: :controller do
    let(:header) { Models::Header.new(title: 'The Title', id: '1234') }

    context 'GET #show' do
      before { controller.runner = runner }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: yields, callback_name: callback_name, run_with: { header_id: header.to_param }, context: controller
        )
      end

      context 'when :doi_not_assigned' do
        let(:yields) { header }
        let(:callback_name) { :doi_not_assigned }
        it 'will render the show page' do
          get 'show', header_id: header.to_param
          expect(flash[:alert]).to_not be_empty
          expect(assigns(:model)).to respond_to(:submit)
          expect(assigns(:model).header).to be_decorated
          expect(response).to render_template('doi_not_assigned')
        end
      end

      context 'when :doi_already_assigned' do
        let(:yields) { header }
        let(:callback_name) { :doi_already_assigned }
        it 'will redirect to the header page' do
          get 'show', header_id: header.to_param
          expect(flash[:notice]).to_not be_empty
          expect(assigns(:model)).to be_nil
          expect(response).to redirect_to header_path(header.to_param)
        end
      end

      context 'when :doi_request_is_pending' do
        let(:doi_request) { double }
        let(:yields) { [header, doi_request] }
        let(:callback_name) { :doi_request_is_pending }
        it 'will redirect to the header page' do
          get 'show', header_id: header.to_param
          expect(flash[:notice]).to_not be_empty
          expect(assigns(:model)).to be_nil
          expect(response).to redirect_to header_path(header.to_param)
        end
      end
    end

    context 'POST #assign_a_doi' do
      before { controller.runner = runner }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: yields, callback_name: callback_name, context: controller,
          run_with: { header_id: header.to_param, identifier: identifier }
        )
      end

      context 'when :success' do
        let(:yields) { [header, identifier] }
        let(:callback_name) { :success }
        let(:identifier) { 'doi:abc' }
        it 'will redirect to the header page' do
          post 'assign_a_doi', header_id: header.to_param, doi: { identifier: identifier }
          expect(flash[:notice]).to_not be_empty
          expect(response).to redirect_to(header_path(header.to_param))
        end
      end

      context 'when :failure' do
        let(:yields) { header }
        let(:identifier) { 'doi:abc' }
        let(:callback_name) { :failure }
        it 'will render the "assign" template' do
          post 'assign_a_doi', header_id: header.to_param, doi: { identifier: identifier }
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('assign_a_doi')
        end
      end
    end

    context 'POST #request_a_doi' do
      before { controller.runner = runner }
      let(:attributes) do
        { 'authors' => ['Hello World'], 'publication_date' => '2014-11-25', 'publisher' => ['This is the Publisher'] }
      end
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: yields, callback_name: callback_name, context: controller,
          run_with: { header_id: header.to_param, attributes: attributes }
        )
      end

      context 'when :success' do
        let(:yields) { header }
        let(:callback_name) { :success }
        let(:identifier) { 'doi:abc' }
        it 'will redirect to the header page' do
          post 'request_a_doi', header_id: header.to_param, doi: attributes
          expect(flash[:notice]).to_not be_empty
          expect(response).to redirect_to(header_path(header.to_param))
        end
      end

      context 'when :failure' do
        let(:identifier) { 'doi:abc' }
        let(:yields) { header }
        let(:callback_name) { :failure }
        it 'will render the "request_a_doi" template' do
          post 'request_a_doi', header_id: header.to_param, doi: attributes
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('request_a_doi')
        end
      end
    end
  end
end
