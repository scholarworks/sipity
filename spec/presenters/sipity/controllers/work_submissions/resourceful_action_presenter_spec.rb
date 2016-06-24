require "rails_helper"
require 'sipity/controllers/work_submissions/resourceful_action_presenter'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/work_submissions/resourceful_action_presenter'

module Sipity
  module Controllers
    module WorkSubmissions
      RSpec.describe ResourcefulActionPresenter, type: :presenter do
        let(:context) { PresenterHelper::Context.new(current_user: current_user) }
        let(:current_user) { double('Current User') }
        let(:work_submission) { Models::Work.new(id: '123') }
        let(:resourceful_action) { Models::Processing::StrategyAction.new(name: 'show') }
        subject { described_class.new(context, resourceful_action: resourceful_action, work_submission: work_submission) }

        it "will have a path based on the work area query action" do
          expect(subject.path).to eq("/work_submissions/#{work_submission.id}/do/show")
        end
      end
    end
  end
end
