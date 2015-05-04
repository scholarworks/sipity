require 'spec_helper'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/work_areas/resourceful_action_presenter'

module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe ResourcefulActionPresenter, type: :presenter do
        let(:context) do
          PresenterHelper::Context.new(work_area: work_area, current_user: current_user, resourceful_action: resourceful_action)
        end
        let(:current_user) { double('Current User') }
        let(:work_area) { Models::WorkArea.new(slug: 'the-slug') }
        let(:resourceful_action) { Models::Processing::StrategyAction.new(name: 'show') }
        subject { described_class.new(context, resourceful_action: resourceful_action, work_area: work_area) }

        it "will have a path based on the work area query action" do
          expect(subject.path).to eq("/areas/#{work_area.slug}/do/#{resourceful_action.name}")
        end

        its(:work_area_slug) { should eq(work_area.slug) }
      end
    end
  end
end
