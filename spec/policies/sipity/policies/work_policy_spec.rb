require 'spec_helper'
require 'sipity/policies/work_policy'

module Sipity
  module Policies
    RSpec.describe WorkPolicy do
      let(:user) { User.new(id: '1') }
      let(:work) { Models::Work.new(id: '2') }
      subject { WorkPolicy.new(user, work) }

      it 'will delegate all other methods to ProcessingEntityPolicy' do
        expect(Processing::ProcessingEntityPolicy).to receive(:call).with(user: user, entity: work, action_to_authorize: :show?)
        subject.show?
      end

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:create?) { is_expected.to eq(false) }
      end

      context 'for an authenticated user' do
        context 'with an new work' do
          before { allow(work).to receive(:persisted?).and_return(false) }
          its(:create?) { is_expected.to eq(true) }
        end
        context 'with an existing work' do
          before do
            allow(work).to receive(:persisted?).and_return(true)
          end
          its(:create?) { is_expected.to eq(false) }
        end
      end
    end
  end
end
