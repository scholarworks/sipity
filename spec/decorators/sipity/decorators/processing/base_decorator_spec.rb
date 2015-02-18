require 'spec_helper'

module Sipity
  module Decorators
    module Processing
      RSpec.describe BaseDecorator do
        ENTITY_ID = '1234'
        let(:entity) { Models::Work.new(id: ENTITY_ID) }
        let(:action) { double(name: 'herd', action_type: 'cattle') }
        subject { described_class.new(action: action, entity: entity) }

        its(:name) { should eq(action.name) }
        its(:action_type) { should eq(action.action_type) }
        its(:path) { should eq('/works/1234/herd') }
      end
    end
  end
end
