require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe BasePolicy do
      let(:user) { double('User') }
      let(:entity) { double('Entity') }
      subject { BasePolicy.new(nil, nil) }
      it 'exposes a .call function for convenience' do
        allow_any_instance_of(BasePolicy).to receive(:show?)
        BasePolicy.call(user: user, entity: entity, policy_method_name: :show?)
      end
      it 'requires that you implement :show?' do
        expect { subject.show? }.to raise_error(NotImplementedError)
      end
      it 'requires that you implement :create?' do
        expect { subject.create? }.to raise_error(NotImplementedError)
      end
      it 'requires that you implement :update?' do
        expect { subject.update? }.to raise_error(NotImplementedError)
      end
      it 'requires that you implement :destroy?' do
        expect { subject.destroy? }.to raise_error(NotImplementedError)
      end
    end
  end
end
