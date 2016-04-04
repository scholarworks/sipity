require 'spec_helper'
require 'sipity/controllers/work_areas/ulra/show_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Ulra
        RSpec.describe ShowPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new(current_user: current_user, request: double(path: '/path'), paginate: true) }
          let(:current_user) { double('Current User') }
          let(:work_area) { double(slug: 'the-slug', title: 'The Slug', processing_state: 'new', order: 'title', page: 1) }
          let(:repository) { QueryRepositoryInterface.new }
          let(:translator) { double(call: true) }
          subject { described_class.new(context, work_area: work_area, repository: repository, translator: translator) }
          it { is_expected.to be_a(Sipity::Controllers::WorkAreas::Core::ShowPresenter) }

          context 'when there are open submission windows' do
            let(:submission_window) { double }
            before do
              allow(repository).to receive(:find_open_submission_windows_by).with(work_area: work_area).and_return(submission_window)
            end
            its(:submission_windows) { is_expected.to eq([submission_window]) }
            its(:submission_windows?) { is_expected.to eq(true) }
          end
          context 'when there are NO open submission windows' do
            before do
              allow(repository).to receive(:find_open_submission_windows_by).with(work_area: work_area).and_return([])
            end
            its(:submission_windows) { is_expected.to eq([]) }
            its(:submission_windows?) { is_expected.to eq(false) }
          end
        end
      end
    end
  end
end
