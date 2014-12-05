require 'spec_helper'

module Sipity
  module Runners
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
    end
  end
end
