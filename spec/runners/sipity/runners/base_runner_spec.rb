require 'spec_helper'

module Sipity
  module Runners
    include RunnersSupport
    RSpec.describe BaseRunner do
      let(:context) { double('Context') }
      let(:my_options) { {} }
      subject { BaseRunner.new(context, my_options) }

      it 'will not require authentication by default' do
        expect(BaseRunner.authentication_layer).to eq(:none)
      end

      it 'will not require authorization by default' do
        expect(BaseRunner.enforces_authorization).to be_falsey
      end

      it 'will require you to implement #run' do
        expect { subject.run }.to raise_error(NotImplementedError)
      end

      it { should respond_to :repository }
      it { should respond_to :current_user }

      context 'when authentication is required' do
        let(:my_options) { { authentication_layer: double(call: true) } }

        context 'and the authentication service returns false' do
          it 'will raise an AuthenticationFailureError on instantiation' do
            expect(my_options[:authentication_layer]).to receive(:call).with(context).and_return(false)
            expect { BaseRunner.new(context, my_options) }.to raise_error(Exceptions::AuthenticationFailureError)
          end
        end

        context 'and the authentication service succeeds' do
          it 'will successfully instantiate (and be ready to run)' do
            expect(my_options[:authentication_layer]).to receive(:call).with(context).and_return(true)
            expect(BaseRunner.new(context, my_options)).to be_a(BaseRunner)
          end
        end
      end

      context 'when authentication is NOT required' do
        let(:my_options) { { authentication_layer: double(call: true) } }
        it 'will not call the underlying authentication_service' do
          expect(BaseRunner.new(context, my_options)).to be_a(BaseRunner)
        end
      end

      context 'when the authentication layer is mis-configured' do
        it 'will raise an error' do
          expect { BaseRunner.new(context, authentication_layer: :borked) }.
            to raise_error(Exceptions::FailedToBuildAuthenticationLayerError)
        end
      end

      context 'when enforcing the authorization layer' do
        let(:user) { double('User') }
        let(:handler) { double(invoked: true) }
        let(:authorization_layer) { double('AuthorizationLayer', enforce!: true) }
        let(:entity) { double('Entity') }
        let(:context) { TestRunnerContext.new(current_user: user, authorization_layer: authorization_layer) }
        before do
          MyRunner = Class.new(BaseRunner) do
            def run(entity:, policy_question:)
              authorization_layer.enforce!(policy_question, entity) do
                callback(:success, entity)
              end
            end
          end
        end
        after do
          Sipity::Runners.send(:remove_const, :MyRunner)
        end
        subject do
          MyRunner.new(context, authorization_layer: authorization_layer) do |on|
            on.success { |a| handler.invoked('SUCCESS', a) }
          end
        end
        it 'will enforce! the policy then yield control to the runner' do
          expect(authorization_layer).to receive(:enforce!).with(:show?, entity).and_yield
          response = subject.run(entity: entity, policy_question: :show?)
          expect(handler).to have_received(:invoked).with('SUCCESS', entity)
          expect(response).to eq([:success, entity])
        end
      end
    end
  end
end
