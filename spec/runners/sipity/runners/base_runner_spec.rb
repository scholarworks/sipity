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

      it 'has a default enforces_authorization' do
        expect(BaseRunner.enforces_authorization).to be_falsey
      end

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
        it 'will issue the :unauthorized callback then fail' do
          expect(authorization_layer).to receive(:enforce!).with(:show?, entity).and_yield
          subject.run(entity: entity, policy_question: :show?)
        end
      end
    end
  end
end
