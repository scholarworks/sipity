require 'spec_helper'

module Sipity
  module Services
    RSpec.describe AuthorizationLayer do
      subject { described_class.new(context, policy_authorizer: policy_authorizer) }
      let(:entity) { Models::Work.new(id: '2') }
      let(:context) { double(current_user: User.new(id: '1')) }
      let(:action_to_authorize) { :create? }
      let(:policy_authorizer) { double('PolicyAuthorizer', call: :called) }

      it 'will have a default policy_authorizer' do
        authorization_layer = described_class.new(context)
        expect(authorization_layer.send(:policy_authorizer)).to respond_to(:call)
      end

      context '#enforce!' do
        let(:user) { User.new }

        context 'when each policy is authorized' do
          it 'will yield to the caller' do
            allow(policy_authorizer).to receive(:call).and_return(true)
            expect { |b| subject.enforce!(show?: entity, edit?: entity, &b) }.
              to yield_control
          end
        end

        context 'when one of the policies is unauthorized' do
          before { allow(policy_authorizer).to receive(:call).and_return(false) }
          it 'will raise an exception and not yield to the caller' do
            allow(policy_authorizer).to receive(:call).
              with(user: context.current_user, action_to_authorize: :create?, entity: entity).and_return(true)
            allow(policy_authorizer).to receive(:call).
              with(user: context.current_user, action_to_authorize: :show?, entity: entity).and_return(false)
            expect do |b|
              expect do
                subject.enforce!(create?: entity, show?: entity, &b)
              end.to raise_exception(Exceptions::AuthorizationFailureError)
            end.to_not yield_control
          end

          it 'will issue an :unauthorized callback if the context responds to #callback' do
            expect(context).to receive(:callback).with(:unauthorized)
            expect do
              subject.enforce!(show?: entity)
            end.to raise_exception(Exceptions::AuthorizationFailureError)
          end
        end
      end
    end

    RSpec.describe AuthorizationLayer::AuthorizeEverything do
      let(:context) { double }
      subject { described_class.new(context) }
      context '#enforce!' do
        it 'will be very permissive and always yield to the caller' do
          expect { |b| subject.enforce!(&b) }.to yield_control
        end
      end
    end
  end
end
