require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe EnrichSipByFormSubmissionPolicy do
      let(:user) { User.new(id: '1') }
      let(:work) { Models::Sip.new(id: '2') }
      let(:entity) { double(work: work) }
      let(:work_policy) { double('Sip Policy') }
      subject { EnrichSipByFormSubmissionPolicy.new(user, entity, work_policy: work_policy) }

      it 'will have a default work_policy' do
        expect(EnrichSipByFormSubmissionPolicy.new(user, entity).send(:work_policy)).to be_a(SipPolicy)
      end

      it 'will fail to initialize if the entity does not have a #work' do
        entity = double
        expect { EnrichSipByFormSubmissionPolicy.new(user, entity, work_policy: work_policy) }.
          to raise_error Exceptions::PolicyEntityExpectationError
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:submit?) { should eq(false) }
      end

      context 'for an authenticated user' do
        context 'with a new work' do
          before { allow(work).to receive(:persisted?).and_return(false) }
          its(:submit?) { should eq(false) }
        end
        context 'with an existing work' do
          before do
            allow(work).to receive(:persisted?).and_return(true)
          end
          context 'its :submit?' do
            it 'will delegate to the provided work_policy' do
              expect(work_policy).to receive(:update?).and_return(true)
              expect(subject.submit?).to eq(true)
            end
          end
        end
      end
    end
  end
end
