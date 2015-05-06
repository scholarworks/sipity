module Sipity
  module Queries
    RSpec.describe SubmissionWindowQueries, type: :isolated_repository_module do
      let(:work_area) do
        Models::WorkArea.new(id: 1, name: 'worm', slug: 'worm', partial_suffix: 'worm', demodulized_class_prefix_name: 'Worm')
      end
      context '#find_submission_window_by' do
        let(:submission_window) do
          Models::SubmissionWindow.create!(work_area_id: work_area.id, slug: 'segment')
        end

        it 'will find by slug and work area' do
          expect(test_repository.find_submission_window_by(slug: submission_window.slug, work_area: work_area)).
            to eq(submission_window)
        end

        it 'will raise an error if we have a bad work area' do
          expect { test_repository.find_submission_window_by(slug: submission_window.slug, work_area: nil) }.
            to raise_error(PowerConverter::ConversionError)
        end

        it 'will raise an error if the submission window and work area are out of sync' do
          submission_window = Models::SubmissionWindow.create!(work_area_id: work_area.id + 1, slug: 'segment')
          expect { test_repository.find_submission_window_by(slug: submission_window.slug, work_area: work_area) }.
            to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'will raise an error if the submission window does not exist' do
          expect { test_repository.find_submission_window_by(slug: 'another-slug', work_area: work_area) }.
            to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
