require 'spec_helper'

module Sipity
  RSpec.describe AuthorizationLayer do
    subject { described_class.new(context) }
    let(:entity) { Models::Header.new(id: '2') }
    let(:context) { double(current_user: User.new(id: '1')) }
    let(:policy_question) { :create? }

    context '#enforce!' do
      let(:user) { User.new }

      context 'when each policy is authorized' do
        it 'will yield to the caller' do
          allow(subject).to receive(:policy_authorized_for?).and_return(true)
          expect { |b| subject.enforce!(show?: entity, edit?: entity, &b) }.
            to yield_control
        end
      end

      context 'when one of the policies is unauthorized' do
        before { allow(subject).to receive(:policy_authorized_for?).and_return(false) }
        it 'will raise an exception and not yield to the caller' do
          expect(subject).to receive(:policy_authorized_for?).
            with(user: context.current_user, policy_question: :create?, entity: entity).and_return(true)
          expect(subject).to receive(:policy_authorized_for?).
            with(user: context.current_user, policy_question: :show?, entity: entity).and_return(false)
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

    context 'private methods (for completeness)' do
      let(:user) { double('User') }
      let(:policy_enforcer) { double('Policy Enforcer', call: true) }
      let(:entity) { double('Entity', policy_enforcer: policy_enforcer) }
      context '#policy_authorized_for?' do
        it 'will use the found policy_enforcer' do
          allow(subject).to receive(:find_policy_enforcer_for).with(entity: entity).and_return(policy_enforcer)
          expect(policy_enforcer).to receive(:call).with(user: user, entity: entity, policy_question: policy_question)
          subject.send(:policy_authorized_for?, user: user, policy_question: policy_question, entity: entity)
        end
      end
      context '#find_policy_enforcer_for' do
        it "will use an entity's policy_enforcer if one is found" do
          expect(subject.send(:find_policy_enforcer_for, entity: entity)).to eq(entity.policy_enforcer)
        end

        it "will lookup one by convention" do
          header = Models::Header.new
          expect(subject.send(:find_policy_enforcer_for, entity: header)).to eq(Policies::HeaderPolicy)
        end

        it "will fail if a policy_enforcer cannot be found" do
          expect { subject.send(:find_policy_enforcer_for, entity: double) }.to raise_error Exceptions::PolicyNotFoundError
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
