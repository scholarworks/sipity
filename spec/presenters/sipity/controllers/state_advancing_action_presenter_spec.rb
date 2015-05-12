require 'spec_helper'
# Because RSpec's described_class is getting confused
require 'sipity/controllers/state_advancing_action_presenter'

module Sipity
  module Controllers
    RSpec.describe StateAdvancingActionPresenter, type: :presenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user) }
      let(:current_user) { double('Current User') }
      let(:state_advancing_action) { Models::Processing::StrategyAction.new(name: 'create_a_window', id: 1) }
      let(:entity) { Models::Work.new(id: '12ab') }
      let(:repository) { QueryRepositoryInterface.new }
      let(:state_advancing_action_set) do
        Parameters::ActionSetParameter.new(identifier: 'required', collection: [state_advancing_action], entity: entity)
      end
      subject do
        described_class.new(
          context,
          state_advancing_action: state_advancing_action,
          state_advancing_action_set: state_advancing_action_set,
          repository: repository
        )
      end

      # TODO: This is provisional
      its(:default_repository) { should be_a(QueryRepository)}

      its(:action_name) { should eq(state_advancing_action.name) }
      its(:path) { should be_a(String) }

      # TODO: This is provisional and should be translated
      its(:label) { should eq(state_advancing_action.name) }
      its(:available?) { should eq(true) }
    end
  end
end
