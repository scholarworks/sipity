require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe WorkEnrichmentsController, type: :controller do
      let(:work) { double('Work') }
      context 'GET #edit' do
        let(:enrichment_type) { 'attach' }
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name,
            run_with: { enrichment_type: enrichment_type, work_id: work.to_param }, context: controller
          )
        end
        let(:yields) { work }
        let(:callback_name) { :success }
        it 'will render the edit page' do
          get 'edit', work_id: work.to_param, enrichment_type: enrichment_type
          expect(assigns(:model)).to_not be_nil
        end
      end
    end
  end
end
