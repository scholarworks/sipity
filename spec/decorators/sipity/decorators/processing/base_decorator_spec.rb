require 'spec_helper'

module Sipity
  module Decorators
    module Processing
      RSpec.describe BaseDecorator do
        let(:entity) { Models::Work.new(id: '1234') }
        let(:action) { double(name: 'herd', action_type: 'cattle') }
        let(:user) { double('User') }
        subject { described_class.new(action: action, entity: entity, user: user) }

        its(:name) { should eq(action.name) }
        its(:action_type) { should eq(action.action_type) }
        its(:path) { should eq("/works/#{entity.id}/herd") }
      end
    end
  end
end
