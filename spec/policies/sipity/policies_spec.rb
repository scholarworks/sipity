require 'spec_helper'
require 'sipity/policies'

module Sipity
  RSpec.describe Policies do
    subject { described_class }
    let(:user) { double('User') }
    let(:policy_enforcer) { double('Policy Enforcer', call: true) }
    let(:policy_question) { :show? }
    let(:entity) { double('Entity', policy_enforcer: policy_enforcer) }

    context '#authorized_for?' do
      it 'will use the found policy_enforcer' do
        allow(subject).to receive(:find_policy_enforcer_for).with(entity: entity).and_return(policy_enforcer)
        expect(policy_enforcer).to receive(:call).with(user: user, entity: entity, policy_question: policy_question)
        subject.authorized_for?(user: user, policy_question: policy_question, entity: entity)
      end
    end

    context '#find_policy_enforcer_for' do
      it "will use an entity's policy_enforcer if one is found" do
        expect(subject.find_policy_enforcer_for(entity: entity)).to eq(entity.policy_enforcer)
      end

      it "will lookup one by convention" do
        sip = Models::Sip.new
        expect(subject.find_policy_enforcer_for(entity: sip)).to eq(Policies::SipPolicy)
      end

      it "will fail if a policy_enforcer cannot be found" do
        expect { subject.find_policy_enforcer_for(entity: double) }.to raise_error Exceptions::PolicyNotFoundError
      end
    end
  end
end
