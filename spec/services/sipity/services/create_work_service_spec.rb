require 'rails_helper'

module Sipity
  module Services
    RSpec.describe CreateWorkService do
      let(:attributes) { { title: 'Hello', work_publication_strategy: 'do_not_know', work_type: 'doctoral_dissertation' } }
      let(:pid_minter) { double(call: '1') }
      let(:strategy) { double('Strategy', id: 2) }
      let(:state) { double('Strategy State', id: 3) }
      let(:work_type) { Models::WorkType.new }
      let(:work_area) { Models::WorkArea.new(slug: 'etd', id: 6) }
      let(:submission_window) { Models::SubmissionWindow.new(id: 5, slug: 'start', work_area_id: work_area.id) }
      subject { described_class.new(attributes.merge(pid_minter: pid_minter, submission_window: submission_window)) }

      it 'will create a work object and associated processing entity' do
        expect(DataGenerators::FindOrCreateWorkType).to receive(:call).
          with(name: 'doctoral_dissertation').and_yield(work_type, strategy, state)
        expect do
          expect do
            expect do
              expect(subject.call).to be_a(Models::Work)
            end.to change { Models::Work.count }.by(1)
          end.to change { Models::Processing::Entity.count }.by(1)
        end.to change { Models::WorkSubmission.count }.by(1)
      end

      it 'will assign a default submission window' do
        repository = CommandRepositoryInterface.new
        expect(repository).to receive(:find_submission_window_by).and_return(submission_window)
        described_class.new(pid_minter: pid_minter, repository: repository, **attributes)
      end
    end
  end
end
