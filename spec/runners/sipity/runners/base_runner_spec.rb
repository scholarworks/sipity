require 'spec_helper'
require 'sipity/runners/base_runner'

module Sipity
  module Runners
    include RunnersSupport
    RSpec.describe BaseRunner do
      before do
        class MockRunner < BaseRunner
          def run(*)
            enforce_authentication!
          end
        end
      end

      after do
        Sipity::Runners.send(:remove_const, :MockRunner)
      end

      let(:context) { double('Context') }
      let(:my_options) { {} }
      subject { BaseRunner.new(context, my_options) }

      it 'will not require authentication by default' do
        expect(BaseRunner.authentication_layer).to eq(:none)
      end

      it 'will not require authorization by default' do
        expect(BaseRunner.authorization_layer).to eq(:none)
      end

      it 'will require you to implement #run' do
        expect { subject.run }.to raise_error(NotImplementedError)
      end

      it { is_expected.to respond_to :repository }
      it { is_expected.to respond_to :current_user }

      it 'will have an #action_name' do
        expect(subject.action_name).to eq('base_runner')
      end

      context 'authentication layer coordination' do
        context 'with the :default authentication layer' do
          it 'will delegate authentication to the given context (because Devise)' do
            expect(context).to receive(:authenticate_user!).and_return(true)
            MockRunner.new(context, authentication_layer: :default).run
          end
        end

        context 'when authentication is called' do
          let(:my_options) { { authentication_layer: double(call: true) } }

          context 'and returns false' do
            it 'will raise an AuthenticationFailureError on instantiation' do
              expect(my_options[:authentication_layer]).to receive(:call).with(context).and_return(false)
              expect { MockRunner.new(context, my_options).run }.to raise_error(Exceptions::AuthenticationFailureError)
            end
          end
        end

        it 'will successfully instantiate (and be ready to run) without attempting to enforce the authentication layer' do
          expect(BaseRunner.new(context, my_options)).to be_a(BaseRunner)
        end

        context 'when the authentication layer is mis-configured' do
          it 'will raise an error' do
            expect { BaseRunner.new(context, authentication_layer: :borked) }.
              to raise_error(Exceptions::FailedToBuildAuthenticationLayerError)
          end
        end
      end

      context 'authorization layer coordination' do
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(current_user: user) }

        context 'when enforcing the authorization layer' do
          let(:handler) { double(invoked: true) }
          let(:enforcer) { double('Enforcer', enforce!: true) }
          let(:authorization_layer) { double('AuthorizationLayer', call: enforcer) }
          let(:entity) { double('Entity') }
          before do
            MyRunner = Class.new(BaseRunner) do
              def run(entity:, action_to_authorize:)
                authorization_layer.enforce!(action_to_authorize, entity) do
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
            expect(enforcer).to receive(:enforce!).with(:show?, entity).and_yield
            response = subject.run(entity: entity, action_to_authorize: :show?)
            expect(handler).to have_received(:invoked).with('SUCCESS', entity)
            expect(response).to eq([:success, entity])
          end
        end

        context 'with the :default authorization layer' do
          it 'instantiate a layer that exposes #enforce!' do
            runner = BaseRunner.new(context, authorization_layer: :default)
            expect(runner.send(:authorization_layer)).to respond_to(:enforce!)
          end
        end

        context 'when authorization layer is mis-configured' do
          it 'will raise an error' do
            expect { BaseRunner.new(context, authorization_layer: :borked) }.
              to raise_error(Exceptions::FailedToBuildAuthorizationLayerError)
          end
        end
      end
    end
  end
end
