module Sipity
  module Queries
    RSpec.describe WorkAreaQueries, type: :isolated_repository_module do
      let(:work_area) do
        Models::WorkArea.create!(name: 'worm', slug: 'worm', partial_suffix: 'worm', demodulized_class_prefix_name: 'Worm')
      end
      context '#find_works_area_by' do
        it 'will find by slug' do
          expect(test_repository.find_work_area_by(slug: work_area.slug)).to eq(work_area)
        end
      end
      context '#find_submission_window_by' do
        let(:submission_window) do
          Models::SubmissionWindow.create!(work_area: work_area, slug: 'segment')
        end
        it 'will find by slug and work area' do
          expect(test_repository.find_submission_window_by(slug: submission_window.slug, work_area: work_area.slug)).
            to eq(submission_window)
        end
      end
    end
  end
end
