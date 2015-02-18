require 'spec_helper'

module Sipity
  module Policies
    module Processing
      RSpec.describe WorkProcessingPolicy do
        let(:user) { User.new(id: '1') }
        let(:work) { Models::Work.new(id: '2') }
        let(:repository) { double('Repository') }
        subject { described_class.new(user, work, repository: repository) }
        it 'will query the underlying processing system for answers by :action_name' do
          expect(repository).to receive(:authorized_for_processing?).with(user: user, entity: work, action: :show).and_return(true)
          expect(subject.authorize?(:show)).to be_truthy
        end

        context 'default configuration' do
          subject { described_class.new(user, work) }
          its(:repository) { should respond_to(:authorized_for_processing?) }
        end
      end
    end
  end
end
