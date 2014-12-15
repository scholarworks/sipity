require 'spec_helper'
require 'sipity/runners/header_runners'

module Sipity
  module Runners
    module HeaderRunners
      include RunnersSupport
      RSpec.describe New do
        let(:header) { double }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(build_create_header_form: header) }
        let(:handler) { double(invoked: true) }
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
          response = subject.run
          expect(handler).to have_received(:invoked).with("SUCCESS", header)
          expect(response).to eq([:success, header])
        end
      end

      RSpec.describe Create do
        let(:header) { double('Header') }
        let(:form) { double('Form') }
        let(:user) { User.new(id: '1') }
        let(:context) do
          TestRunnerContext.new(
            current_user: user,
            build_create_header_form: form, submit_create_header_form: creation_response,
            policy_authorized_for?: true
          )
        end
        let(:creation_response) { nil }
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
            on.failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        context 'when header is saved' do
          let(:creation_response) { header }
          it 'will issue the :success callback and return the header' do
            response = subject.run(attributes: {})
            expect(handler).to have_received(:invoked).with("SUCCESS", header)
            expect(response).to eq([:success, header])
          end
        end

        context 'when header is not saved' do
          let(:creation_response) { false }
          it 'will issue the :failure callback and return the form' do
            response = subject.run(attributes: {})
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end
      end

      RSpec.describe Show do
        let(:header) { double }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(find_header: header, current_user: user) }
        let(:handler) { double(invoked: true) }
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
          response = subject.run(header_id: 1234)
          expect(handler).to have_received(:invoked).with("SUCCESS", header)
          expect(response).to eq([:success, header])
        end
      end

      RSpec.describe Index do
        let(:header) { double('Header') }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(current_user: user, find_headers_for: [header]) }
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'will return only a list of objects that I can see' do
          subject.run
          expect(context.repository).to have_received(:find_headers_for).with(user: user)
        end

        it 'issues the :success callback' do
          response = subject.run
          expect(handler).to have_received(:invoked).with("SUCCESS", [header])
          expect(response).to eq([:success, [header]])
        end
      end

      RSpec.describe Edit do
        let(:header) { Models::Header.new(id: '123', title: 'My Title') }
        let(:form) { double('Form') }
        let(:context) { TestRunnerContext.new(find_header: header, build_update_header_form: form) }
        let(:handler) { double(invoked: true) }
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

        context 'when header is found' do
          it 'will issue the :success callback and return the header' do
            response = subject.run(header_id: '123')
            expect(handler).to have_received(:invoked).with('SUCCESS', form)
            expect(response).to eq([:success, form])
          end
        end
      end

      RSpec.describe Update do
        let(:header) { double('Header') }
        let(:form) { double('Form') }
        let(:user) { double('User') }
        let(:context) do
          TestRunnerContext.new(
            find_header: header, build_update_header_form: form, submit_update_header_form: update_response, current_user: user
          )
        end
        let(:update_response) { nil }
        let(:handler) { double(invoked: true) }
        let(:attributes) { {} }

        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
            on.failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        context 'when header is updated' do
          let(:update_response) { header }
          it 'will issue the :success callback and return the header' do
            response = subject.run(header_id: '123', attributes: attributes)
            expect(handler).to have_received(:invoked).with('SUCCESS', header)
            expect(response).to eq([:success, header])
          end
        end

        context 'when header update fails' do
          let(:update_response) { false }
          it 'will issue the :failure callback and return the form' do
            response = subject.run(header_id: '123', attributes: attributes)
            expect(handler).to have_received(:invoked).with('FAILURE', form)
            expect(response).to eq([:failure, form])
          end
        end
      end
    end
  end
end
