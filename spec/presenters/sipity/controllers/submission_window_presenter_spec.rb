module Sipity
  module Controllers
    RSpec.describe SubmissionWindowPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(submission_window: submission_window, current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:submission_window) { Models::SubmissionWindow.new(slug: 'the-slug', work_area: work_area) }
      let(:work_area) { Models::WorkArea.new(slug: 'work-area') }
      let(:repository) { QueryRepositoryInterface.new }
      subject { described_class.new(context, submission_window: submission_window, repository: repository) }

      its(:slug) { should eq(submission_window.slug) }
      its(:work_area_slug) { should eq(work_area.slug) }
      its(:path) { should eq("/areas/#{work_area.slug}/#{submission_window.slug}") }
      its(:link) { should eq(%(<a href="/areas/#{work_area.slug}/#{submission_window.slug}">the-slug</a>)) }
    end
  end
end
