require 'spec_helper'
require 'sipity/runners/description_runners'

module Sipity
  module Runners
    module DescriptionRunners
      include RunnersSupport
      RSpec.describe New do
        let(:work) { double }
        let(:form) { double('Form', submit: true,  work: work, abstract_key: 'key') }
        let(:work_id) { 1234 }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(build_create_describe_work_form: work) }
        let(:handler) { double(invoked: true) }
        let(:context) do
          TestRunnerContext.new(find_work: work, build_create_describe_work_form: form)
        end
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :success callback' do
          response = subject.run(work_id: work_id)
          expect(handler).to have_received(:invoked).with("SUCCESS", form)
          expect(response).to eq([:success, form])
        end
      end
    end
  end
end