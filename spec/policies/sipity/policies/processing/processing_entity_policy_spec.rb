require "rails_helper"
require 'sipity/policies/processing/processing_entity_policy'

module Sipity
  module Policies
    module Processing
      RSpec.describe ProcessingEntityPolicy do
        let(:user) { User.new(id: '1') }
        let(:work) { Models::Work.new(id: '2') }
        let(:repository) { double('Repository') }
        subject { described_class.new(user, work, repository: repository) }

        it 'will capture method missing and attempt an authorize?' do
          expect(repository).to receive(:authorized_for_processing?).with(user: user, entity: work, action: :show?).and_return(true)
          expect(subject.show?).to be_truthy
        end

        it 'will query the underlying processing system for answers by :action_name' do
          expect(repository).to receive(:authorized_for_processing?).with(user: user, entity: work, action: :show).and_return(true)
          expect(subject.authorize?(:show)).to be_truthy
        end

        it 'exposes .call as a convenience method' do
          expect_any_instance_of(described_class).to receive(:authorize?).with(:show)
          described_class.call(user: user, entity: work, action_to_authorize: :show)
        end

        context 'default configuration' do
          subject { described_class.new(user, work) }
          its(:repository) { is_expected.to respond_to(:authorized_for_processing?) }
        end
      end
    end
  end
end
