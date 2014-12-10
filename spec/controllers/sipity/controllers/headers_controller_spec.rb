require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe HeadersController, type: :controller do
      let(:header) { Models::Header.new(title: 'The Title', id: '1234') }

      context 'GET #new' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: [], context: controller
          )
        end

        let(:yields) { header }
        let(:callback_name) { :success }
        it 'will render the edit page' do
          get 'new'
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('new')
        end
      end

      context 'GET #edit' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { header_id: header.to_param }, context: controller
          )
        end

        let(:yields) { header }
        let(:callback_name) { :success }
        it 'will render the edit page' do
          get 'edit', id: header.to_param
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
