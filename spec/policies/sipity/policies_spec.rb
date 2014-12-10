require 'spec_helper'

module Sipity
  RSpec.describe Policies do
    subject { described_class }
    let(:entity) { Models::Header.new(id: '2') }
    let(:user) { User.new(id: '1') }
    let(:policy_question) { :create? }

    context '#with_authorization_enforcement' do
      context 'when policy is authorized' do
        before { allow(subject).to receive(:policy_authorized_for?).and_return(true) }
        it 'will yield to the caller' do
          expect { |b| subject.with_authorization_enforcement(user: user, entity: entity, policy_question: policy_question, &b) }.
            to yield_control
        end
      end

      context 'when policy is unauthorized' do
        before { allow(subject).to receive(:policy_authorized_for?).and_return(false) }
        it 'will raise an exception and not yield to the caller' do
          expect do |b|
            expect do
              subject.with_authorization_enforcement(user: user, entity: entity, policy_question: policy_question, &b)
            end.to raise_exception(Exceptions::AuthorizationFailureError)
          end.to_not yield_control
        end
      end
    end

    context '#policy_authorized_for?' do
      # TODO: The handoff to the policy class is unpleasant. But appears to
      #   work
      it 'works for a Header and a New/Create runner' do
        allow(entity).to receive(:persisted?).and_return(true)
        expect(subject.policy_authorized_for?(user: user, policy_question: policy_question, entity: entity)).
          to eq(false)
      end
    end

    context '#find_policy_enforcer_for' do
      context 'with a #policy_enforcer defined on the model' do
        let(:entity) { double(policy_enforcer: :my_builder) }
        it 'will use the response of the #policy_enforcer' do
          expect(subject.find_policy_enforcer_for(entity)).to eq(:my_builder)
        end
      end

      context 'without a #policy_enforcer defined on the model' do
        it 'will interpolate what the policy should be' do
          expect(subject.find_policy_enforcer_for(entity)).to eq(Policies::HeaderPolicy)
        end
      end
    end
  end
end
