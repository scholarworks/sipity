require "rails_helper"
require 'sipity/policies/base_policy'

module Sipity
  module Policies
    RSpec.describe BasePolicy do
      let(:policy) { double('Policy') }
      let(:user) { double('User') }
      let(:entity) { double('Entity') }
      it 'exposes a .call function for convenience' do
        allow(BasePolicy).to receive(:new).with(user, entity).and_return(policy)
        expect(policy).to receive(:show?)
        BasePolicy.call(user: user, entity: entity, action_to_authorize: :show?)
      end

      context '.define_action_to_authorize declaration' do
        before do
          class TestPolicy < BasePolicy
            define_action_to_authorize :create? do
              !entity.persisted?
            end
            define_action_to_authorize :update? do
              entity.persisted?
            end
          end
        end
        subject { TestPolicy.new(user, entity) }
        after { Sipity::Policies.send(:remove_const, :TestPolicy) }

        it 'will expose an instance method' do
          # Making sure I have the right scope.
          allow(entity).to receive(:persisted?).and_return(true)
          expect(subject.update?).to be_truthy
        end

        it 'will requester the given policy question' do
          expect(subject.class.registered_action_to_authorizes.to_a).to eq([:create?, :update?])
        end
      end
    end
  end
end
