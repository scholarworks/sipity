require 'spec_helper'

module Sipity
  module Runners
    include RunnersSupport
    RSpec.describe BaseRunner do
      let(:context) { double('Context') }
      let(:my_options) { {} }
      subject { BaseRunner.new(context, my_options) }

      it 'will not require authentication by default' do
        expect(BaseRunner.requires_authentication).to be_falsey
      end

      it 'has a default authentication_service' do
        expect(BaseRunner.authentication_service).to respond_to(:call)
      end

      its(:policy_question) { should be :policy_always_fails_so_change_it! }

      it { should respond_to :repository }
      it { should respond_to :current_user }

      context 'when authentication is required' do
        let(:my_options) { { requires_authentication: true, authentication_service: double(call: false) } }

        context 'and the authentication service returns false' do
          it 'will raise an AuthenticationFailureError on instantiation' do
            expect(my_options[:authentication_service]).to receive(:call).with(context).and_return(false)
            expect { BaseRunner.new(context, my_options) }.to raise_error(Exceptions::AuthenticationFailureError)
          end
        end

        context 'and the authentication service succeeds' do
          it 'will successfully instantiate (and be ready to run)' do
            expect(my_options[:authentication_service]).to receive(:call).with(context).and_return(true)
            expect(BaseRunner.new(context, my_options)).to be_a(BaseRunner)
          end
        end
      end

      context 'when authentication is NOT required' do
        let(:my_options) { { requires_authentication: false, authentication_service: double } }
        it 'will not call the underlying authentication_service' do
          expect(my_options[:authentication_service]).to_not receive(:call)
          expect(BaseRunner.new(context, my_options)).to be_a(BaseRunner)
        end
      end

      context '.with_authorization_enforcement' do
        let(:user) { double('User') }
        let(:handler) { double(invoked: true) }
        let(:context) { TestRunnerContext.new(current_user: user, policy_authorized_for?: policy_authorized_answer) }
        before do
          MyRunner = Class.new(BaseRunner) do
            def run(entity:, policy_question: :show?)
              with_authorization_enforcement(policy_question, entity) do
                callback(:success, entity)
              end
            end
          end
        end
        after do
          Sipity::Runners.send(:remove_const, :MyRunner)
        end
        subject do
          MyRunner.new(context) do |on|
            on.unauthorized { handler.invoked('UNAUTHORIZED') }
            on.success { |a| handler.invoked('SUCCESS', a) }
          end
        end
        context 'when the request is unauthorized' do
          let(:policy_authorized_answer) { false }
          let(:entity) { double('Entity') }
          it 'will issue the :unauthorized callback then fail' do
            expect { subject.run(entity: entity) }.to raise_error(Sipity::Exceptions::AuthorizationFailureError)
            expect(handler).to have_received(:invoked).with('UNAUTHORIZED')
            expect(handler).to_not have_received(:invoked).with('SUCCESS', entity)
          end
        end

        context 'when the request is authorized' do
          let(:policy_authorized_answer) { true }
          let(:entity) { double('Entity') }
          it 'will yield control and return the result' do
            response = subject.run(entity: entity)
            expect(handler).to have_received(:invoked).with('SUCCESS', entity)
            expect(response).to eq([:success, entity])
          end
        end
      end
    end
  end
end
