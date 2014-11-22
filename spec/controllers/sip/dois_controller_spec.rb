require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sip
  RSpec.describe DoisController, type: :controller do
    context 'GET #show' do
      before { controller.runner = runner }
      let(:header) { double('Header') }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: header,
          callback_name: callback_name,
          run_with: { header_id: '1234' },
          context: controller
        )
      end

      context 'when :doi_not_assigned' do
        let(:callback_name) { :doi_not_assigned }
        it 'will render the show page' do
          get 'show', header_id: '1234'
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('doi_not_assigned')
        end
      end
    end

    context 'PUT #assign' do
      before { controller.runner = runner }
      let(:header) { double('Header', to_param: '1234') }
      let(:runner) do
        Hesburgh::Lib::MockRunner.new(
          yields: [header, identifier],
          callback_name: :success,
          run_with: { header_id: '1234', identifier: identifier },
          context: controller
        )
      end

      context 'when :success' do
        let(:identifier) { 'doi:abc' }
        let(:header) { double(title: 'The Title', to_param: '1234') }
        it 'will render the show page' do
          put 'assign', header_id: '1234', doi: { identifier: identifier }
          expect(flash[:notice]).to_not be_empty
          expect(response).to redirect_to(sip_header_path('1234'))
        end
      end
    end
  end
end
