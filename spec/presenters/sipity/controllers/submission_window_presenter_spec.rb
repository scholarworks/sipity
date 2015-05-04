module Sipity
  module Controllers
    RSpec.describe SubmissionWindowPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(submission_window: submission_window, current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:submission_window) { Models::SubmissionWindow.new(slug: 'the-slug') }
      let(:repository) { QueryRepositoryInterface.new }
      subject { described_class.new(context, submission_window: submission_window, repository: repository) }
      its(:submission_window_slug) { should eq(submission_window.slug) }
    end
  end
end
