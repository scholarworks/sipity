require 'spec_helper'
module Sipity
  module Decorators
    module Processing
      RSpec.describe EnrichmentActionDecorator do
        let(:action) { double('Action') }
        let(:entity) { double('Entity') }
        let(:user) { double('User') }
        it 'will raise an exception if your entity does not have a work type' do
          expect { described_class.new(action: action, entity: entity, user: user) }.to raise_exception(Exceptions::RuntimeError)
        end
      end
    end
  end
end
