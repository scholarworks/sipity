require 'spec_helper'
require 'sipity/runners/work_runners'

module Sipity
  module Runners
    module WorkRunners
      include RunnersSupport
      RSpec.describe New do
        let(:work) { double }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(build_create_work_form: work) }
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
          expect(handler).to have_received(:invoked).with("SUCCESS", work)
          expect(response).to eq([:success, work])
        end

        it 'allows attributes to be set via attributes' do
          attributes = { title: 'Hello World' }
          expect(context.repository).to receive(:build_create_work_form).with(attributes: attributes)
          response = subject.run(attributes: attributes)
          expect(response).to eq([:success, work])
        end
      end

      RSpec.describe Create do
        let(:work) { double('Work') }
        let(:form) { double('Form') }
        let(:user) { User.new(id: '1') }
        let(:context) do
          TestRunnerContext.new(
            current_user: user,
            build_create_work_form: form, submit_create_work_form: creation_response,
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

        context 'when work is saved' do
          let(:creation_response) { work }
          it 'will issue the :success callback and return the work' do
            response = subject.run(attributes: {})
            expect(handler).to have_received(:invoked).with("SUCCESS", work)
            expect(response).to eq([:success, work])
          end
        end

        context 'when work is not saved' do
          let(:creation_response) { false }
          it 'will issue the :failure callback and return the form' do
            response = subject.run(attributes: {})
            expect(handler).to have_received(:invoked).with("FAILURE", form)
            expect(response).to eq([:failure, form])
          end
        end
      end

      RSpec.describe Show do
        let(:work) { double }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(find_work: work, current_user: user) }
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
          response = subject.run(work_id: 1234)
          expect(handler).to have_received(:invoked).with("SUCCESS", work)
          expect(response).to eq([:success, work])
        end
      end

      RSpec.describe Index do
        let(:work) { double('Work') }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(current_user: user, find_works_for: [work]) }
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
          expect(context.repository).to have_received(:find_works_for).with(user: user)
        end

        it 'issues the :success callback' do
          response = subject.run
          expect(handler).to have_received(:invoked).with("SUCCESS", [work])
          expect(response).to eq([:success, [work]])
        end
      end

      RSpec.describe Edit do
        let(:work) { Models::Work.new(id: '123', title: 'My Title') }
        let(:form) { double('Form') }
        let(:context) { TestRunnerContext.new(find_work: work, build_update_work_form: form) }
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

        context 'when work is found' do
          it 'will issue the :success callback and return the work' do
            response = subject.run(work_id: '123')
            expect(handler).to have_received(:invoked).with('SUCCESS', form)
            expect(response).to eq([:success, form])
          end
        end
      end

      RSpec.describe Update do
        let(:work) { double('Work') }
        let(:form) { double('Form') }
        let(:user) { double('User') }
        let(:context) do
          TestRunnerContext.new(
            find_work: work, build_update_work_form: form, submit_update_work_form: update_response, current_user: user
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

        context 'when work is updated' do
          let(:update_response) { work }
          it 'will issue the :success callback and return the work' do
            response = subject.run(work_id: '123', attributes: attributes)
            expect(handler).to have_received(:invoked).with('SUCCESS', work)
            expect(response).to eq([:success, work])
          end
        end

        context 'when work update fails' do
          let(:update_response) { false }
          it 'will issue the :failure callback and return the form' do
            response = subject.run(work_id: '123', attributes: attributes)
            expect(handler).to have_received(:invoked).with('FAILURE', form)
            expect(response).to eq([:failure, form])
          end
        end
      end
    end
  end
end
