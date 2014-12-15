require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe BasePolicy do
      let(:policy) { double('Policy') }
      let(:user) { User.new(id: 1) }
      let(:entity) { Models::Header.new(id: 2) }
      it 'exposes a .call function for convenience' do
        allow(BasePolicy).to receive(:new).with(user, entity).and_return(policy)
        expect(policy).to receive(:show?)
        BasePolicy.call(user: user, entity: entity, policy_question: :show?)
      end

      context '.define_policy_question declaration' do
        before do
          class TestPolicy < BasePolicy
            define_policy_question :create? do
              entity.persisted?
            end
          end
          # Making sure I have the right scope.
          allow(entity).to receive(:persisted?).and_return(true)
        end
        subject { TestPolicy.new(user, entity) }
        after { Sipity::Policies.send(:remove_const, :TestPolicy) }

        it 'will define a method based on the policy question' do
          expect(subject.create?).to be_truthy
        end

        it 'will define a method based on the policy question' do
          expect(subject.policy_questions.to_a).to eq([:create?])
        end
      end
    end
  end
end
