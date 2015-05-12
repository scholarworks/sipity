require 'spec_helper'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/state_advancing_action_set_presenter'

module Sipity
  module Controllers
    RSpec.describe StateAdvancingActionSetPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:state_advancing_action_set) { Parameters::ActionSet.new(collection: [double], entity: double) }
      subject { described_class.new(context, state_advancing_action_set: state_advancing_action_set) }

      its(:enrichment_actions) { should eq(state_advancing_action_set.collection) }
      its(:entity) { should eq(state_advancing_action_set.entity) }
    end
  end
end
