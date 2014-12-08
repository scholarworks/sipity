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
    end
  end
end
