require 'spec_helper'
require 'sipity/runners/base_runner'

module Sipity
  module Runners
    include RunnersSupport
    RSpec.describe BaseRunner do
      let(:context) { double('Context') }
      let(:my_options) { {} }
      subject { BaseRunner.new(context, my_options) }

      context 'default configuration' do
        subject { BaseRunner }
        its(:authentication_layer) { should eq(:none) }
        its(:authorization_layer) { should eq(:none) }
      end

      it 'will require you to implement #run' do
        expect { subject.run }.to raise_error(NotImplementedError)
      end

      it { should respond_to :repository }
      it { should respond_to :current_user }

      it 'will have an #action_name' do
        expect(subject.action_name).to eq('base_runner')
      end

      context '#enforce_authentication!' do
        it 'will raise an error if enforce_authentication is false' do
          expect(subject).to receive(:enforce_authentication).and_return(false)

          expect { subject.enforce_authentication! }.to raise_error(Exceptions::AuthenticationFailureError)
        end
      end

      context '.run' do
        it 'will enforce authentication' do
          expect_any_instance_of(described_class).to receive(:enforce_authentication).and_return(false)
          expect_any_instance_of(described_class).to receive(:callback).with(:unauthenticated)
          expect_any_instance_of(described_class).to_not receive(:run)
          described_class.run(context: context)
        end
      end

      context 'authentication layer coordination' do
        it 'will raise an exception if the authentication layer method does not exist' do
          expect { BaseRunner.new(context, authentication_layer: :bogus) }.to(
            raise_error(Sipity::Exceptions::FailedToBuildAuthenticationLayerError)
          )
        end

        it 'will build a "none" authentication layer if none is given' do
          runner = BaseRunner.new(context, authentication_layer: false)
          expect(runner.send(:authentication_layer)).to respond_to(:call)
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
