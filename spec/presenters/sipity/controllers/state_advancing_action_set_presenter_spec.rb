require 'spec_helper'
require 'sipity/controllers/state_advancing_action_set_presenter'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/state_advancing_action_set_presenter'

module Sipity
  module Controllers
    RSpec.describe StateAdvancingActionSetPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:state_advancing_action_set) do
        Parameters::ActionSetParameter.new(collection: [double], entity: double(processing_state: 'hello'))
      end
      subject { described_class.new(context, state_advancing_action_set: state_advancing_action_set) }

      its(:state_advancing_actions) { is_expected.to eq(state_advancing_action_set.collection) }
      its(:entity) { is_expected.to eq(state_advancing_action_set.entity) }
      its(:processing_state) { is_expected.to eq(state_advancing_action_set.processing_state) }
    end
  end
end
