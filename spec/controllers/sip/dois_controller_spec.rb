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
    end

    context 'PUT #assign' do
      before { controller.runner = runner }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: [header, identifier],
          callback_name: :success,
          run_with: { header_id: header.to_param, identifier: identifier },
          context: controller
        )
      end

      context 'when :success' do
        let(:identifier) { 'doi:abc' }
        it 'will render the show page' do
          put 'assign', header_id: header.to_param, doi: { identifier: identifier }
          expect(flash[:notice]).to_not be_empty
          expect(response).to redirect_to(sip_header_path(header.to_param))
        end
      end
    end
  end
end
