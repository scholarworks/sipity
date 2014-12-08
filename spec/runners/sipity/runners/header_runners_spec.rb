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
          described_class.new(context, requires_authentication: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        it 'requires authorization' do
          allow(subject).to receive(:with_authorization_enforcement).with(:create?, header)
          subject.run
          expect(handler).to_not have_received(:invoked)
        end

        it 'issues the :success callback' do
          response = subject.run
          expect(handler).to have_received(:invoked).with("SUCCESS", header)
          expect(response).to eq([:success, header])
        end
      end

      RSpec.describe Show do
        let(:header) { double }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(find_header: header, current_user: user) }
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, requires_authentication: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        it 'requires authorization' do
          allow(subject).to receive(:with_authorization_enforcement).with(:show?, header)
          subject.run(1234)
          expect(handler).to_not have_received(:invoked)
        end

        it 'issues the :success callback' do
          response = subject.run(1234)
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
          described_class.new(context, requires_authentication: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
            on.failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        it 'requires authorization' do
          allow(subject).to receive(:with_authorization_enforcement).with(:create?, form)
          subject.run(attributes: {})
          expect(handler).to_not have_received(:invoked)
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

      RSpec.describe Edit do
        let(:header) { Models::Header.new(id: '123', title: 'My Title') }
        let(:form) { double('Form') }
        let(:context) { TestRunnerContext.new(find_header: header, build_edit_header_form: form) }
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, requires_authentication: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        context 'when header is found' do
          it 'will issue the :success callback and return the header' do
            response = subject.run('123')
            expect(handler).to have_received(:invoked).with('SUCCESS', form)
            expect(response).to eq([:success, form])
          end
        end
      end

      RSpec.describe Update do
        let(:header) { double('Header') }
        let(:form) { double('Form') }
        let(:context) { double('Context', repository: repository) }
        let(:update_response) { nil }
        let(:repository) do
          double('Repository', find_header: header, build_edit_header_form: form, submit_edit_header_form: update_response)
        end
        let(:handler) { double(invoked: true) }
        let(:attributes) { {} }

        subject do
          described_class.new(context, requires_authentication: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
            on.failure { |a| handler.invoked("FAILURE", a) }
          end
        end

        it 'requires authentication' do
          expect(context).to receive(:authenticate_user!).and_return(true)
          described_class.new(context)
        end

        context 'when header is updated' do
          let(:update_response) { header }
          it 'will issue the :success callback and return the header' do
            response = subject.run('123', attributes: attributes)
            expect(handler).to have_received(:invoked).with('SUCCESS', header)
            expect(response).to eq([:success, header])
          end
        end

        context 'when header update fails' do
          let(:update_response) { false }
          it 'will issue the :failure callback and return the form' do
            response = subject.run('123', attributes: attributes)
            expect(handler).to have_received(:invoked).with('FAILURE', form)
            expect(response).to eq([:failure, form])
          end
        end
      end
    end
  end
end
