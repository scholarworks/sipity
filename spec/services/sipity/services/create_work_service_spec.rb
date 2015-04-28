require 'rails_helper'

module Sipity
  module Services
    RSpec.describe CreateWorkService do
      let(:attributes) { { title: 'Hello', work_publication_strategy: 'do_not_know', work_type: 'doctoral_dissertation' } }
      let(:pid_minter) { double(call: '1') }
      let(:strategy) { double('Strategy', id: 2) }
      let(:state) { double('Strategy State', id: 3) }
      let(:work_type) { Models::WorkType.new }
      subject { described_class.new(attributes.merge(pid_minter: pid_minter)) }

      it 'will create a work object and associated processing entity' do
        expect(DataGenerators::FindOrCreateWorkType).to receive(:call).
          with(name: 'doctoral_dissertation').and_yield(work_type, strategy, state)
        expect do
          expect do
            expect(subject.call).to be_a(Models::Work)
          end.to change { Models::Work.count }.by(1)
        end.to change { Models::Processing::Entity.count }.by(1)
      end
    end
  end
end
