require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe WorkDescriptionsController, type: :controller do
      let(:work) { Models::Work.new(title: 'The Title', id: '1234') }
      context 'GET #new' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
              yields: yields, callback_name: callback_name, run_with: { work_id: work.to_param }, context: controller
          )
        end
        let(:yields) { work }
        let(:callback_name) { :success }
        it 'will render the new page' do
          get 'new', work_id: work.to_param
          expect(assigns(:model)).to_not be_nil
        end
      end
    end
  end
end
