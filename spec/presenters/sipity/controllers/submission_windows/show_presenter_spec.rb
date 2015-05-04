require 'spec_helper'

module Sipity
  module Controllers
    module SubmissionWindows
      RSpec.describe ShowPresenter do
        let(:context) { PresenterHelper::Context.new(submission_window: submission_window, current_user: current_user) }
        let(:current_user) { double('Current User') }
        let(:submission_window) { double(slug: 'the-slug', work_area: work_area) }
        let(:work_area) { double(slug: 'work-area') }
        subject { described_class.new(context, submission_window: submission_window) }
        it { should be_a SubmissionWindowPresenter }
      end
    end
  end
end
