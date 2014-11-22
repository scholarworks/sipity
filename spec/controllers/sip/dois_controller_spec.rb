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
        end
      end
    end
  end
end
