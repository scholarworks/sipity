require 'spec_helper'

module Sipity
  module Decorators
    module Processing
      RSpec.describe StateAdvancingActionDecorator do
        let(:entity) { Models::Work.new(id: 1234) }
        let(:user) { double }
        let(:action) { Models::Processing::StrategyAction.new(name: 'hello')}
        subject { described_class.new(action: action, entity: entity, user: user) }

        it "will have a path" do
          expect(subject.path).to match(%r{/#{entity.id}/trigger/#{action.name}$})
        end
      end
    end
  end
end
