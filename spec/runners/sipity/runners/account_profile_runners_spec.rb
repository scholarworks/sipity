require "rails_helper"
require 'sipity/runners/account_profile_runners'
require 'sipity/runners/account_profile_runners'

module Sipity
  module Runners
    module AccountProfileRunners
      include RunnersSupport
      RSpec.describe Edit do
        let(:user) { double('User') }
        let(:form) { double('Form') }
        let(:context) { TestRunnerContext.new(build_account_profile_form: form) }
        subject do
          described_class.new(context, authentication_layer: false) do |on|
            on.success { |a| context.handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to respond_to(:call)
        end

        it 'issues the :success callback' do
          response = subject.run
          expect(context.handler).to have_received(:invoked).with("SUCCESS", form)
          expect(response).to eq([:success, form])
        end
      end

      RSpec.describe Update do
        let(:form) { double('Form', submit: update_response) }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(current_user_for_profile_management: user, build_account_profile_form: form) }
        let(:update_response) { nil }
        let(:handler) { double(invoked: true) }
        let(:attributes) { {} }

        subject do
          described_class.new(context, authentication_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
            on.failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to respond_to(:call)
        end

        context 'when account profile is updated' do
          let(:update_response) { user }
          it 'will issue the :success callback and return the user' do
            response = subject.run(attributes: attributes)
            expect(handler).to have_received(:invoked).with('SUCCESS', user)
            expect(response).to eq([:success, user])
          end
        end

        context 'when account profile update fails' do
          let(:update_response) { false }
          it 'will issue the :failure callback and return the form' do
            response = subject.run(attributes: attributes)
            expect(handler).to have_received(:invoked).with('FAILURE', form)
            expect(response).to eq([:failure, form])
          end
        end
      end
    end
  end
end
