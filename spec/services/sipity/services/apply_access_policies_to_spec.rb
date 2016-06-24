require 'rails_helper'
require 'sipity/services/apply_access_policies_to'
module Sipity
  module Services
    RSpec.describe ApplyAccessPoliciesTo do
      let(:user) { User.new }
      let(:work) { Models::Work.new(id: 1) }
      let(:attachment) { Models::Attachment.new(id: 2) }
      let(:access_policies) { {} }

      subject { described_class.new(work: work, user: user, access_policies: access_policies) }

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(work: work, user: user, access_policies: access_policies)
      end

      let(:access_policies) do
        { entity_id: 1, entity_type: Sipity::Models::Work, access_right_code: Models::AccessRight::OPEN_ACCESS, release_date: '' }
      end

      it 'create a new AccessRight' do
        expect { subject.call }.to change { Models::AccessRight.count }.by(1)
      end

      it 'will preserve the given access rights based on keyed input' do
        subject.call
        expect { subject.call }.to_not change { Models::AccessRight.count }
      end

      it 'will update an existing access policy with new information' do
        access_right = Models::AccessRight.create!(access_policies)
        attributes = access_policies.merge(access_right_code: Models::AccessRight::PRIVATE_ACCESS)
        subject = described_class.new(work: work, user: user, access_policies: attributes)
        subject.call
        expect(access_right.reload.access_right_code).to eq(Models::AccessRight::PRIVATE_ACCESS)
      end
    end
  end
end
