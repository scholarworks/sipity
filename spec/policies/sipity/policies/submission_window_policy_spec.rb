module Sipity
  module Policies
    RSpec.describe SubmissionWindowPolicy do
      let(:user) { Models::IdentifiableAgent.new_from_netid(netid: 'hworld') }
      let(:work_area) { Models::WorkArea.new(id: '2') }
      subject { described_class.new(user, work_area) }

      it 'will delegate to the Processing::ProcessingEntityPolicy' do
        expect(Processing::ProcessingEntityPolicy).to receive(:call).with(user: user, entity: work_area, action_to_authorize: :create?)
        subject.create?
      end
    end
  end
end
