require "rails_helper"
require 'sipity/controllers/visitors/ulra/work_area_presenter'

module Sipity
  module Controllers
    module Visitors
      module Ulra
        RSpec.describe WorkAreaPresenter do
          let(:context) { PresenterHelper::ContextWithForm.new(current_user: current_user, request: double(path: '/path'), paginate: true) }
          let(:current_user) { double('Current User') }
          let(:work_area) { double(slug: 'the-slug', title: 'The Slug', processing_state: 'new', order: 'title', page: 1) }
          let(:repository) { QueryRepositoryInterface.new }
          let(:translator) { double(call: true) }
          subject { described_class.new(context, work_area: work_area, repository: repository, translator: translator) }

          let(:processing_action) { double(name: 'start_a_submission') }

          before do
            expect(repository).to_not receive(:find_submission_window_by)
            allow_any_instance_of(described_class).to receive(:convert_to_processing_action).and_return(processing_action)
          end

          its(:initialize_submission_window_variables!) { is_expected.to be_nil }

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
              allow(repository).to receive(:find_open_submission_windows_by).with(work_area: work_area).and_return(nil)
            end
            its(:submission_windows) { is_expected.to eq([]) }
            its(:submission_windows?) { is_expected.to eq(false) }
          end
        end
      end
    end
  end
end
