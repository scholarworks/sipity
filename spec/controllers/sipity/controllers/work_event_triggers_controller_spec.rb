require 'spec_helper'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe WorkEventTriggersController, type: :controller do
      let(:work) { double('Work', persisted?: true, title: 'Hello World') }
      let(:event_name) { 'submit_for_review' }
      context 'GET #new' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yielded_object, callback_name: callback_name, context: controller,
            run_with: { event_name: event_name, work_id: work.to_param }
          )
        end
        let(:yielded_object) { work }
        let(:callback_name) { :success }
        it 'will render the new page' do
          get 'new', work_id: work.to_param, event_name: event_name
          expect(assigns(:model)).to_not be_nil
        end
      end
    end
  end
end
