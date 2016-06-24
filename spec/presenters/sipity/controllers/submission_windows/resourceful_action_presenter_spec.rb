require "rails_helper"
require 'sipity/controllers/submission_windows/resourceful_action_presenter'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/submission_windows/resourceful_action_presenter'

module Sipity
  module Controllers
    module SubmissionWindows
      RSpec.describe ResourcefulActionPresenter, type: :presenter do
        let(:context) do
          PresenterHelper::Context.new(
            submission_window: submission_window, current_user: current_user, resourceful_action: resourceful_action
          )
        end
        let(:current_user) { double('Current User') }
        let(:work_area) { Models::WorkArea.new(slug: 'the-slug') }
        let(:submission_window) { Models::SubmissionWindow.new(slug: 'the-slug', work_area: work_area) }
        let(:resourceful_action) { Models::Processing::StrategyAction.new(name: 'show') }
        subject { described_class.new(context, resourceful_action: resourceful_action, submission_window: submission_window) }

        it "will have a path based on the work area query action" do
          expect(subject.path).to eq("/areas/#{submission_window.work_area_slug}/#{submission_window.slug}/do/#{resourceful_action.name}")
        end

        its(:work_area_slug) { is_expected.to eq(submission_window.work_area_slug) }
        its(:submission_window_slug) { is_expected.to eq(submission_window.slug) }
      end
    end
  end
end
