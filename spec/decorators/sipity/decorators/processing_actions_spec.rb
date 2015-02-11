require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe ProcessingActions do
      let(:user) { double('User') }
      let(:repository) { double('Repository', scope_permitted_strategy_actions_available_for_current_state: actions) }
      let(:entity) { double('Entity') }

      let(:actions) do
        [
          Models::Processing::StrategyAction.new(action_type: 'enrichment_action'),
          Models::Processing::StrategyAction.new(action_type: 'resourceful_action'),
          Models::Processing::StrategyAction.new(action_type: 'state_advancing_action')
        ]
      end

      subject { described_class.new(user: user, entity: entity, repository: repository) }

      its(:enrichment_actions) { should be_a Enumerable }
      its(:resourceful_actions) { should be_a Enumerable }
      its(:state_advancing_actions) { should be_a Enumerable }
    end
  end
end
