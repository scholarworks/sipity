require "rails_helper"
require 'sipity/runners/dashboard_runners'
require 'sipity/runners/dashboard_runners'

module Sipity
  module Runners
    module DashboardRunners
      include RunnersSupport
      RSpec.describe Index do
        let(:user) { User.new }
        let(:context) { TestRunnerContext.new(current_user: user, build_dashboard_view: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| context.handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'does not enforce authorization (as it uses authorization-related scoped finders)' do
          expect(described_class.authorization_layer).to eq(:none)
        end

        it 'issues the :success callback' do
          view_object = double
          expect(context.repository).
            to receive(:build_dashboard_view).
            with(user: user, filter: { processing_state: :hello_dolly }, page: 1).
            and_return(view_object)
          response = subject.run(processing_state: :hello_dolly)
          expect(context.handler).to have_received(:invoked).with("SUCCESS", view_object)
          expect(response).to eq([:success, view_object])
        end
      end
    end
  end
end
