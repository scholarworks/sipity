require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe EnrichSipByFormSubmissionPolicy do
      let(:user) { User.new(id: '1') }
      let(:sip) { Models::Sip.new(id: '2') }
      let(:entity) { double(sip: sip) }
      let(:sip_policy) { double('Sip Policy') }
      subject { EnrichSipByFormSubmissionPolicy.new(user, entity, sip_policy: sip_policy) }

      it 'will have a default sip_policy' do
        expect(EnrichSipByFormSubmissionPolicy.new(user, entity).send(:sip_policy)).to be_a(SipPolicy)
      end

      it 'will fail to initialize if the entity does not have a #sip' do
        entity = double
        expect { EnrichSipByFormSubmissionPolicy.new(user, entity, sip_policy: sip_policy) }.
          to raise_error Exceptions::PolicyEntityExpectationError
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:submit?) { should eq(false) }
      end

      context 'for an authenticated user' do
        context 'with a new sip' do
          before { allow(sip).to receive(:persisted?).and_return(false) }
          its(:submit?) { should eq(false) }
        end
        context 'with an existing sip' do
          before do
            allow(sip).to receive(:persisted?).and_return(true)
          end
          context 'its :submit?' do
            it 'will delegate to the provided sip_policy' do
              expect(sip_policy).to receive(:update?).and_return(true)
              expect(subject.submit?).to eq(true)
            end
          end
        end
      end
    end
  end
end
