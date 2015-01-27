require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe WorkEventTriggerPolicy do
      let(:user) { User.new(id: 123) }
      let(:work) { Models::Work.new(id: 123, work_type: 'etd') }
      subject { described_class.new(user, work) }

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:submit?) { should eq(false) }
      end

      context 'for a non-persisted entity' do
        its(:submit?) { should eq(false) }
      end

      context 'for a user and persisted entity' do
        before { expect(work).to receive(:persisted?).and_return(true) }
        xit 'will disallow attempting to submit a trigger for a work in an incorrect state'
        xit 'will disallow attempting to submit a trigger that they do not have access to for the given work'
        xit 'will disallow attempting to submit a trigger for a work in which all todo items are not complete'
      end
    end
  end
end
