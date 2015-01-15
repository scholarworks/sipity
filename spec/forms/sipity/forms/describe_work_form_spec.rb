require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe DescribeWorkForm do
      let(:work) { Models::Work.new(id: '1234') }
      subject { described_class.new(work: work) }

      its(:policy_enforcer) { should eq Policies::EnrichWorkByFormSubmissionPolicy }

      it { should respond_to :work }
      it { should respond_to :abstract }
      it { should respond_to :abstract= }

      it 'will require a abstract' do
        subject.valid?
        expect(subject.errors[:abstract]).to be_present
      end

      it 'will require a work' do
        subject = described_class.new(work: nil)
        subject.valid?
        expect(subject.errors[:work]).to_not be_empty
      end
    end
  end
end
