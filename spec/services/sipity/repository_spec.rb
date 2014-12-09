require 'rails_helper'

module Sipity
  RSpec.describe Repository, type: :repository do
    subject { Repository }
    its(:included_modules) { should include(Sipity::Repo::HeaderMethods) }
    its(:included_modules) { should include(Sipity::Repo::DoiMethods) }
    its(:included_modules) { should include(Sipity::Repo::CitationMethods) }

    it 'will delegate #policy_authorized_for? to Policies' do
      user, policy_question, entity = double, double, double
      allow(Policies).to receive(:policy_authorized_for?).with(user: user, policy_question: policy_question, entity: entity)
      described_class.new.policy_authorized_for?(user: user, policy_question: policy_question, entity: entity)
    end
  end
end
