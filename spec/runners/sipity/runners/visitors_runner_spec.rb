require 'spec_helper'
require 'sipity/runners/visitors_runner'
require 'sipity/runners/visitors_runner'

module Sipity
  module Runners
    module VisitorsRunner
      include RunnersSupport
      RSpec.describe WorkArea do
        context 'configuration' do
          subject { described_class }
          its(:authentication_layer) { should eq(:none) }
          its(:authorization_layer) { should eq(:none) }
        end

        context '#run' do
          subject do
            described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
              on.success { |a| handler.invoked("SUCCESS", a) }
            end
          end

          let(:context) { TestRunnerContext.new(find_work_area_by: work_area) }
          let(:handler) { double(invoked: true) }
          let(:work_area) { double }

          it 'issues the :success callback' do
            response = subject.run(work_area_slug: 'a_work_area')
            expect(handler).to have_received(:invoked).with("SUCCESS", work_area)
            expect(response).to eq([:success, work_area])
          end

          it 'allows for a processing_action_name to be passed (because upstream assumes as much)' do
            expect { subject.run(work_area_slug: 'a_work_area', processing_action_name: 'work_area') }.to_not raise_error
          end
        end
      end
    end
  end
end
